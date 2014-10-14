require "Cocos2d"
require "Cocos2dConstants"

SC = class("DbReader",function() 
    SC.__index = DbReader
end)
db = nil

function DbReader:getInstance()
    if (db == nil) then DbReader.create()
    return db;
end
function DbReader.create()
    local me = DbReader.new()
    me.db = cc.UserDefault:getInstance()
    return me
end
function DbReader:getStarsForLevel(level)
    return DbReader.db:getIntegerForKey("level_stars",0)
end
function DbReader:unlockLevel(lvl)
    db:setBoolForKey(lvl+"_level_completed",true);
end
function DbReader:isLevelUnlocked(const int val)
    return db:getBoolForKey(lvl+"_level_completed", false);
end
DbReader:flush()
    db:flush()
end
bool DbReader::isTutorialCmpltd(const std::string &tutorialName)
{
    if (db->getBoolForKey("TUTORIALS_ENABLED", true))
    {
        return db->getBoolForKey(tutorialName.c_str(), false); //tut completed
    }
    return true;
}
bool DbReader::areTutorialsEnabled()
{
    return db->getBoolForKey("TUTORIALS_ENABLED", true);
}
void DbReader::setTutorialCmpltd(const std::string &tutorialName)
{
    db->setBoolForKey(tutorialName.c_str(), true);
}
bool DbReader::areBasicTutorialsCompleted()
{
    return isTutorialCmpltd("firstTut.json");
}
void DbReader::setTutorialsEnabled(bool vl)
{
    CCLOG("Setting ads disabled");
    db->setBoolForKey("TUTORIALS_ENABLED", vl);
    CCLOG("After setting ads disabled");
}

bool DbReader::isRatedOrLiked()
{
    return db->getBoolForKey("RATEDORLIKED", false);
}

void DbReader::setRatedOrLiked(bool val)
{
    db->setBoolForKey("RATEDORLIKED", val);
}

bool DbReader::areAdsEnabled()
{
    return db->getBoolForKey("ADSENABLED", true);
}

void DbReader::setAdsEnabled(bool val)
{
    CCLOG("Setting ads disabled");
    db->setBoolForKey("ADSENABLED", val);
    CCLOG("after Setting ads disabled");
}
void DbReader::setLevelsEnabledAll(bool val)
{
    CCLOG("Unlocking all levels");
    db->setBoolForKey("ALLLEVELSENABLED",true);
    for(int i=1;i<=9;i++)
    {
        unlockLevel(i);
    }
    CCLOG("After unlocking all levels");
}
void DbReader::incrementLevelTry(int level)
{
    int prevValue = getLevelTries(level);
    db->setIntegerForKey(("LEVEL "+std::to_string(level) + " TRIES").c_str(), prevValue+1);
}
int DbReader::getLevelTries(int level)
{
    return db->getIntegerForKey(("LEVEL "+std::to_string(level) + " TRIES").c_str(),0);
}
