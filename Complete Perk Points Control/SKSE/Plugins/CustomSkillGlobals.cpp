#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/spdlog.h>

#include <algorithm>
#include <cstdint>
#include <fstream>
#include <string>
#include <unordered_map>
#include <vector>

#include "RE/Skyrim.h"
#include "SKSE/SKSE.h"

using namespace RE;
using namespace SKSE;
namespace logger = SKSE::log;

static TESGlobal* GetGlobal(const char* id) { return TESForm::LookupByEditorID<TESGlobal>(id); }

static TESGlobal* g_mcmMenuEnabled = nullptr;
static TESGlobal* g_modEnabled = nullptr;
static TESGlobal* g_customModEnabled = nullptr;
static TESGlobal* g_startingLevel = nullptr;
static TESGlobal* g_levelInterval = nullptr;
static TESGlobal* g_multiplier = nullptr;
static TESGlobal* g_maxSkillLevel = nullptr;
static TESGlobal* g_globalMode = nullptr;

static std::vector<TESGlobal*> g_activeSkillGlobals;

struct SkillData {
    int lastLevel = 0;
    int perkPointsGiven = 0;
};

struct GlobalSkillData {
    int totalProgress = 0;
    int perkPointsGiven = 0;
};

using SkillKey = FormID;

static std::unordered_map<SkillKey, SkillData> g_skillData;
static GlobalSkillData g_globalSkillData;

void SetupLogger() {
    auto path = logger::log_directory();
    if (!path) return;

    *path /= "CustomSkillPoints.log";

    auto sink = std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true);

    sink->set_pattern("[%Y-%m-%d %H:%M:%S] [%l] %v");

    auto log = std::make_shared<spdlog::logger>("CPP", sink);
    log->set_level(spdlog::level::info);
    log->flush_on(spdlog::level::info);  // warn

    spdlog::set_default_logger(log);
}

static std::vector<std::string> LoadSkillGlobalsFromFile() {
    std::vector<std::string> result;

    std::ifstream file("Data/SKSE/Plugins/CustomSkillGlobals.txt");
    if (!file.is_open()) {
        logger::warn("CustomSkillGlobals.txt not found");
        return result;
    }

    std::string line;
    while (std::getline(file, line)) {
        line.erase(0, line.find_first_not_of(" \t\r\n"));
        line.erase(line.find_last_not_of(" \t\r\n") + 1);

        if (line.empty() || line.starts_with("#")) continue;

        result.push_back(line);
    }

    logger::info("Loaded {} skill globals", result.size());
    return result;
}

void InitGlobals() {
    g_mcmMenuEnabled = GetGlobal("CPP_CustomSkills_MCMEnabled");
    g_modEnabled = GetGlobal("CPP_ModEnabled");
    g_customModEnabled = GetGlobal("CPP_CustomSkills_Enabled");
    g_startingLevel = GetGlobal("CPP_CustomSkills_StartingLevel");
    g_levelInterval = GetGlobal("CPP_CustomSkills_LevelInterval");
    g_maxSkillLevel = GetGlobal("CPP_CustomSkills_MaxLevel");
    g_multiplier = GetGlobal("CPP_CustomSkills_PerkPointsMultiplier");
    g_globalMode = GetGlobal("CPP_CustomSkills_GlobalProgressionMode");

    g_activeSkillGlobals.clear();

    for (auto& id : LoadSkillGlobalsFromFile()) {
        if (auto* g = GetGlobal(id.c_str())) {
            g_activeSkillGlobals.push_back(g);
            logger::info("Detected custom skill: {}", id);
        } else {
            logger::warn("Global not found: {}", id);
        }
    }
}

bool ValidateGlobals() {
    if (!g_modEnabled || !g_customModEnabled || !g_startingLevel || !g_levelInterval || !g_multiplier ||
        !g_maxSkillLevel) {
        logger::error("Missing required globals");
        return false;
    }

    if (g_levelInterval->value <= 0.0f) {
        logger::error("CPP_LevelInterval must be > 0");
        return false;
    }

    return true;
}

void ProcessNormalSkill(PlayerCharacter* player, TESGlobal* skillGlobal, SkillData& data) {
    int skillLevel = static_cast<int>(skillGlobal->value);
    int starting = static_cast<int>(g_startingLevel->value);
    int interval = static_cast<int>(g_levelInterval->value);
    int maxLevel = static_cast<int>(g_maxSkillLevel->value);
    int multiplier = static_cast<int>(g_multiplier->value);

    int baseline = starting - interval;
    int pointsDeserved = ((skillLevel - baseline) / interval) * multiplier;

    if (pointsDeserved <= data.perkPointsGiven || pointsDeserved <= 0) return;

    int diff = pointsDeserved - data.perkPointsGiven;

    auto& stats = player->GetGameStatsData();
    stats.perkCount = static_cast<int8_t>(std::clamp(stats.perkCount + diff, 0, 127));

    if (skillLevel == maxLevel)
        data.perkPointsGiven = 0;
    else
        data.perkPointsGiven = pointsDeserved;

    data.lastLevel = skillLevel;

    logger::info("[NORMAL] {} +{} perk points", skillGlobal->GetFormEditorID(), diff);
}

void ProcessGlobalSkill(PlayerCharacter* player, TESGlobal* skillGlobal, SkillData& data) {
    int currentLevel = static_cast<int>(skillGlobal->value);
    int starting = static_cast<int>(g_startingLevel->value);

    if (currentLevel < starting) {
        data.lastLevel = currentLevel;
        return;
    }

    int lastEffectiveLevel = std::max(data.lastLevel, starting);
    int progress = currentLevel - lastEffectiveLevel;

    if (progress < 0) {
        progress = 0;
    }

    if (progress > 0) {
        g_globalSkillData.totalProgress += progress;
    }

    int interval = static_cast<int>(g_levelInterval->value);
    int multiplier = static_cast<int>(g_multiplier->value);

    int pointsDeserved = (g_globalSkillData.totalProgress / interval) * multiplier;

    if (pointsDeserved > g_globalSkillData.perkPointsGiven) {
        int diff = pointsDeserved - g_globalSkillData.perkPointsGiven;

        auto& stats = player->GetGameStatsData();
        stats.perkCount = static_cast<int8_t>(std::clamp(stats.perkCount + diff, 0, 127));

        g_globalSkillData.perkPointsGiven = pointsDeserved;

        logger::info("[GLOBAL] +{} perk points", diff);
    }

    data.lastLevel = currentLevel;
}

void ProcessSkill(PlayerCharacter* player, TESGlobal* g) {
    auto& data = g_skillData[g->GetFormID()];
    bool globalMode = !g_globalMode || g_globalMode->value >= 1.0f;

    if (globalMode)
        ProcessGlobalSkill(player, g, data);
    else
        ProcessNormalSkill(player, g, data);
}

void ProcessCustomSkills(PlayerCharacter* player) {
    if (!player || !g_modEnabled || g_modEnabled->value == 0.0f  || !g_customModEnabled ||
        g_customModEnabled->value == 0.0f)
        return;

    for (auto* g : g_activeSkillGlobals) {
        ProcessSkill(player, g);
    }
}

void Save(SKSE::SerializationInterface* intfc) {
    if (!intfc->OpenRecord('CPPC', 1)) return;

    uint32_t count = static_cast<uint32_t>(g_skillData.size());
    intfc->WriteRecordData(&count, sizeof(count));

    for (auto& [id, data] : g_skillData) {
        intfc->WriteRecordData(&id, sizeof(id));
        intfc->WriteRecordData(&data, sizeof(data));
    }

    intfc->WriteRecordData(&g_globalSkillData, sizeof(g_globalSkillData));
}

void Load(SKSE::SerializationInterface* intfc) {
    uint32_t type, version, length;

    while (intfc->GetNextRecordInfo(type, version, length)) {
        if (type != 'CPPC') continue;

        uint32_t count;
        intfc->ReadRecordData(&count, sizeof(count));

        for (uint32_t i = 0; i < count; i++) {
            SkillKey id;
            SkillData data;
            intfc->ReadRecordData(&id, sizeof(id));
            intfc->ReadRecordData(&data, sizeof(data));
            g_skillData[id] = data;
        }

        intfc->ReadRecordData(&g_globalSkillData, sizeof(g_globalSkillData));
    }
}

class MenuOpenEventSink : public BSTEventSink<MenuOpenCloseEvent> {
public:
    BSEventNotifyControl ProcessEvent(const MenuOpenCloseEvent* evn, BSTEventSource<MenuOpenCloseEvent>*) override {
        if (!evn || !evn->opening) return BSEventNotifyControl::kContinue;

        if (evn->menuName == StatsMenu::MENU_NAME) {
            if (auto* player = PlayerCharacter::GetSingleton()) ProcessCustomSkills(player);
        }

        return BSEventNotifyControl::kContinue;
    }

    static void Install() {
        static MenuOpenEventSink sink;
        UI::GetSingleton()->AddEventSink<MenuOpenCloseEvent>(&sink);
    }
};

void OnSKSEMessage(SKSE::MessagingInterface::Message* msg) {
    if (msg->type == SKSE::MessagingInterface::kDataLoaded) {
        InitGlobals();

        if (g_mcmMenuEnabled) {
            g_mcmMenuEnabled->value = 1.0f;
            logger::info("MCM availability flag set");
        }

        ValidateGlobals();
    }
}

SKSEPluginLoad(const SKSE::LoadInterface* skse) {
    SKSE::Init(skse);
    SetupLogger();

    SKSE::GetMessagingInterface()->RegisterListener(OnSKSEMessage);

    auto* ser = SKSE::GetSerializationInterface();
    ser->SetUniqueID('CPPS');
    ser->SetSaveCallback(Save);
    ser->SetLoadCallback(Load);

    MenuOpenEventSink::Install();

    logger::info("CustomSkillGlobals loaded");
    return true;
}
