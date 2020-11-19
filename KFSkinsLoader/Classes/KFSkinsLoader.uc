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
var config string sNotifyOnSkinChange;
var config bool bForceCustomChars, bImplementAsServerPackages, bDebug;

// Mut Vars
var transient array<name> AddedServerPackages;
var array<PlayerController> PendingPlayers;


function PreBeginPlay()
{
  // Critical | If you do not want to add skins as ServerPackages, set this to true
  if(bImplementAsServerPackages) AddSkinsToServer();
}

// Trigger
function PostBeginPlay()
{
  // Apply Default Config, uncomment to generate default .ini
	SaveConfig();
}

function bool AddCustomSkins()
{
	local int i, j;

	for(i=0;i<CustomSkin.Length;i++)
	{
		j = class'KFGameType'.Default.AvailableChars.Length;
		if(!SkinAlreadyAdded(CustomSkin[i].SkinCode)) class'KFGameType'.Default.AvailableChars[j] = CustomSkin[i].SkinCode;
	}

  return true;
}

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

function bool SkinAlreadyAdded(string SkinCode)
{
	local int i;
	for(i=0;i<class'KFGameType'.Default.AvailableChars.Length;i++)
	{
		if(class'KFGameType'.Default.AvailableChars[i] ~= SkinCode) return true;
	}
	return false;
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(PlayerController(Other)!=None)
	{
		PendingPlayers[PendingPlayers.Length] = PlayerController(Other);

    // Timer from 0.1 to 1.0 | Patch from Flame
    SetTimer(fReplacementTimer, false);
	}

  return true;
}

function Timer()
{
	local int i;
	for(i=0;i<PendingPlayers.Length;i++)
	{
		if(PendingPlayers[i]!=None) LoadSkinsToPlayers(PendingPlayers[i]);
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
function LoadSkinsToPlayers(PlayerController PC)
{
	local int i;

	for(i=0; i < CustomSkin.Length; i++)
	{
    PC.SetPawnClass("", CustomSkin[i].SkinCode);
	}

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
  bForceCustomChars = False
  bImplementAsServerPackages = True
  fReplacementTimer = 5
  // CustomSkin(0)=(SkinCode="KFSkinsLoader.iDoNotExist",AddDate="01.01.1945")
}
