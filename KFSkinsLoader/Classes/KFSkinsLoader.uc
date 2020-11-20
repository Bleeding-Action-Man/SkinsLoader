//////////////////////////////////////////////
// Load custom skins without ServerPerks
// Originally made by Flame, Edited by Vel-San
//////////////////////////////////////////////

class KFSkinsLoader extends Mutator Config(CustomSkinsConfig);

struct Skin
{
  var config string SkinCode;
  var config string SkinDescription;
  var config string AddDate;
};

// Config Var for SkinsList
var config array<Skin> CustomSkin;
var config float fReplacementTimer;
var config bool bForceCustomChars, bAddAsServerPackages, bDebug;

// Mut Vars
var transient array<name> AddedServerPackages;
var array<PlayerController> PendingPlayers;

function PreBeginPlay()
{
  // Critical
  if(bAddAsServerPackages) AddSkinsToServer();
}

function PostBeginPlay()
{
  // Apply Default Config, uncomment to generate default .ini
  SaveConfig();
}

// Add Skins to AvailableChars list
function bool AddCustomSkins()
{
  local int i, j;

  for(i=0;i<CustomSkin.Length;i++)
  {
    j = KFGameType(Level.Game).AvailableChars.Length;
    if(!SkinAlreadyAdded(CustomSkin[i].SkinCode)) KFGameType(Level.Game).AvailableChars[j] = CustomSkin[i].SkinCode;
  }
  return true;
}

// Add Skins to server as ServerPackages
function AddSkinsToServer()
{
  local int i;
  local array<string> PackageName;

  if(bDebug) MutLog("-----|| DEBUG - Found [" $CustomSkin.Length$ "] Skins in Config||-----");
  for( i=0; i<CustomSkin.Length; ++i )
  {
    SplitStringToArray(PackageName, CustomSkin[i].SkinCode, ".");
    AddToPackageMap(PackageName[0]);
    if(bDebug) MutLog("-----|| DEBUG - Skin [" $PackageName[0]$ "] Added to ServerPackages ||-----");
  }
}

// Check is Skin is already added
function bool SkinAlreadyAdded(string SkinCode)
{
  local int i;
  for(i=0;i<KFGameType(Level.Game).AvailableChars.Length;i++)
  {
    if(KFGameType(Level.Game).AvailableChars[i] ~= SkinCode) return true;
  }
  return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
  if(PlayerController(Other)!=None)
  {
    PendingPlayers[PendingPlayers.Length] = PlayerController(Other);
    SetTimer(fReplacementTimer, false);
  }
  return true;
}

function Timer()
{
  local int i;
  for(i=0;i<PendingPlayers.Length;i++)
  {
    if(PendingPlayers[i]!=None) ForceSkins(PendingPlayers[i]);
  }

  PendingPlayers.Length = 0;
}

function Tick(float dt)
{
  // Add Custom Skins
  if(AddCustomSkins()) Disable('Tick');
  Super.Tick(dt);
}

// Load all Skins to players, Force select if bForceCustomChars = True
function ForceSkins(PlayerController PC)
{
  /*local int i;
  for(i=0; i < CustomSkin.Length; i++)
  {
    PC.SetPawnClass("", CustomSkin[i].SkinCode);
  }*/

  if(bForceCustomChars) PC.PlayerReplicationInfo.SetCharacterName(CustomSkin[Rand(CustomSkin.Length)].SkinCode);
}

final function SplitStringToArray(out array<string> Parts, string Source, string Delim)
{
  Split(Source, Delim, Parts);
}

function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'SkinsLoader');
}

function MutLog(string s)
{
  log(s, 'SkinsLoader');
}

defaultproperties
{
  // Mandatory Vars
  GroupName="KF-SkinsLoader"
  FriendlyName="Skins Loader - v1.0"
  Description="Load custom skins into the game without ServerPerks; Originally made by Flame, Edited by Vel-San"

  // Default Config
  bDebug = True
  bForceCustomChars = True
  fReplacementTimer = 5
  bAddAsServerPackages = True
}
