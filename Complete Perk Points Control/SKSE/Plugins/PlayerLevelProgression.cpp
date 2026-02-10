#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/spdlog.h>

#include <algorithm>
#include <format>
#include <memory>

#include "RE/Skyrim.h"
#include "SKSE/SKSE.h"

using namespace RE;
using namespace SKSE;

namespace logger = SKSE::log;

static TESGlobal* GetGlobal(const char* a_editorID) { return TESForm::LookupByEditorID<TESGlobal>(a_editorID); }

static TESGlobal* g_modEnabled = nullptr;
static TESGlobal* g_playerLevelModeEnabled = nullptr;
static TESGlobal* g_startingLevel = nullptr;
static TESGlobal* g_levelInterval = nullptr;
static TESGlobal* g_multiplier = nullptr;
static TESGlobal* g_pointsEarned = nullptr;

void InitGlobals() {
    g_modEnabled = GetGlobal("CPP_ModEnabled");
    g_playerLevelModeEnabled = GetGlobal("CPP_PlayerLevelMode_Enabled");
    g_pointsEarned = GetGlobal("CPP_PlayerLevelMode_PerkPointsEarned");
    g_startingLevel = GetGlobal("CPP_StartingLevel");
    g_levelInterval = GetGlobal("CPP_LevelInterval");
    g_multiplier = GetGlobal("CPP_PerkPointsMultiplier");
    if (!g_modEnabled || !g_playerLevelModeEnabled || !g_startingLevel || !g_levelInterval || !g_multiplier ||
        !g_pointsEarned) {
        logger::error("One or more globals could not be found");
    } else {
        logger::info("Globals initialized");
    }
}

void HandlePlayerLevelUp(PlayerCharacter* player) {

    if (!player || !g_modEnabled || !g_playerLevelModeEnabled || !g_startingLevel || !g_levelInterval ||
        !g_multiplier || !g_pointsEarned) {
        return;
    }

    if (g_modEnabled->value == 0.0f || g_playerLevelModeEnabled->value == 0.0f) {
        return;
    }

    const int playerLevel = player->GetLevel();
    const int startingLevel = static_cast<int>(g_startingLevel->value);
    const int interval = static_cast<int>(g_levelInterval->value);
    const int multiplier = static_cast<int>(g_multiplier->value);

    if (interval <= 0 || playerLevel < startingLevel) {
        return;
    }

    const int baseline = startingLevel - interval;
    const int pointsDeserved = ((playerLevel - baseline) / interval) * multiplier;

    const int pointsEarned = static_cast<int>(g_pointsEarned->value);

    if (pointsEarned >= pointsDeserved) {
        return;
    }

    const int diff = pointsDeserved - pointsEarned;

    auto& stats = player->GetGameStatsData();

    int newValue = static_cast<int>(stats.perkCount) + diff;
    newValue = std::clamp(newValue, 0, 127);

    stats.perkCount = static_cast<std::int8_t>(newValue);

    g_pointsEarned->value = static_cast<float>(pointsDeserved);

    logger::info("PlayerLevelMode: level={} added={} total={}", playerLevel, diff, pointsDeserved);
}

class LevelUpMenuEventSink : public BSTEventSink<MenuOpenCloseEvent> {
public:
    static LevelUpMenuEventSink* GetSingleton() {
        static LevelUpMenuEventSink instance;
        return std::addressof(instance);
    }

    BSEventNotifyControl ProcessEvent(const MenuOpenCloseEvent* a_event, BSTEventSource<MenuOpenCloseEvent>*) override {
        if (!a_event || !a_event->opening) {
            return BSEventNotifyControl::kContinue;
        }

        if (a_event->menuName != "LevelUp Menu") {
            return BSEventNotifyControl::kContinue;
        }

        auto* player = PlayerCharacter::GetSingleton();
        if (!player) {
            logger::warn("LevelUp Menu opened but PlayerCharacter is null");
            return BSEventNotifyControl::kContinue;
        }

        HandlePlayerLevelUp(player);
        return BSEventNotifyControl::kContinue;
    }
};

void RegisterMenuListener() {
    auto* ui = UI::GetSingleton();
    if (!ui) {
        logger::error("UI singleton not found");
        return;
    }

    ui->AddEventSink(LevelUpMenuEventSink::GetSingleton());
    logger::info("LevelUp Menu listener registered");
}

void SetupLogger() {
    auto path = logger::log_directory();
    if (!path) {
        return;
    }

    *path /= "CPP_PlayerLevelProgression.log";

    auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true);

    sink->set_pattern("[%Y-%m-%d %H:%M:%S] [%l] %v");

    auto log = std::make_shared<spdlog::logger>("CPP", sink);
    log->set_level(spdlog::level::info);
    log->flush_on(spdlog::level::info);

    spdlog::set_default_logger(log);
}

void OnSKSEMessage(SKSE::MessagingInterface::Message* msg) {
    if (!msg) {
        return;
    }

    if (msg->type == SKSE::MessagingInterface::kDataLoaded) {
        logger::info("SKSE kDataLoaded received");

        InitGlobals();
        RegisterMenuListener();
    }
}

SKSEPluginLoad(const SKSE::LoadInterface* skse) {
    SKSE::Init(skse);
    SetupLogger();

    auto* messaging = SKSE::GetMessagingInterface();
    if (!messaging) {
        logger::error("Failed to get MessagingInterface");
        return false;
    }

    messaging->RegisterListener(OnSKSEMessage);

    logger::info("CPP_PlayerLevelProgression loaded (waiting for DataLoaded)");
    return true;
}
