//////////////////////////////////////////////
// Load custom skins without ServerPerks
// Originally made by Flame, Edited by Vel-San
// Contant @ steam: /id/Vel-San
//////////////////////////////////////////////

class KFSkinsLoader extends Mutator Config(CustomSkinsConfig);

struct Skin
{
	var config string SkinCode;
	var config string AddDate;
};

// Config Var for SkinsList
var config array<Skin> CustomSkin;
var config bool bForceCustomChars;

// Mut Vars
var transient array<name> AddedServerPackages;
var array<PlayerController> PendingPlayers;

// Trigger
function PostBeginPlay()
{
  // Apply Default Config, uncomment to generate default .ini
	SaveConfig();

  // Add Custom Skins
	AddCustomSkins();
}

function AddCustomSkins()
{
	local int i, j;

	for(i=0;i<CustomSkin.Length;i++)
	{
		j = class'KFGameType'.Default.AvailableChars.Length;
		if(!SkinAlreadyAdded(CustomSkin[i].SkinCode)) class'KFGameType'.Default.AvailableChars[j] = CustomSkin[i].SkinCode;
	}

  AddSkinsToServer();
}

function AddSkinsToServer()
{
  local int i, j;
	local class<PlayerRecordClass> PR;
	local string S;

  for( i=0; i<CustomSkin.Length; ++i )
	{
		// Separate group from actual skin.
		S = CustomSkin[i].SkinCode;
		j = InStr(S,":");
		if( j>=0 )
			S = Mid(S,j+1);
		PR = class<PlayerRecordClass>(DynamicLoadObject(S$"Mod."$S,class'Class',true));
		if( PR!=None )
		{
			if( PR.Default.MeshName!="" ) // Add Mesh Package.
				ImplementPackage(DynamicLoadObject(PR.Default.MeshName,class'Mesh',true));
			if( PR.Default.BodySkinName!="" ) // Add Skin Package.
				ImplementPackage(DynamicLoadObject(PR.Default.BodySkinName,class'Material',true));
			ImplementPackage(PR);
		}
	}
}

final function ImplementPackage( Object SkinObj )
{
	local int i;

	if( SkinObj == None )
		return;
	while( SkinObj.Outer != None )
		SkinObj = SkinObj.Outer;
	if( SkinObj.Name == 'KFMod' )
		return;
	for( i=(AddedServerPackages.Length-1); i>=0; --i )
		if( AddedServerPackages[i] == SkinObj.Name )
			return;
	AddedServerPackages[AddedServerPackages.Length] = SkinObj.Name;
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
    SetTimer(1.0, false);
	}

  if( ClientPerkRepLink(Other)!=None ) SetupRepLink(ClientPerkRepLink(Other));
	return true;
}

function SetupRepLink( ClientPerkRepLink R )
{
	local int i;

	R.bNoStandardChars = bForceCustomChars;
	R.CustomChars = CustomCharacters;
}

function Timer()
{
	local int i;
	for(i=0;i<PendingPlayers.Length;i++)
	{
		if(PendingPlayers[i]!=None)
			LoadSkinsToPlayers(PendingPlayers[i]);
	}
	PendingPlayers.Length = 0;
}

// Load all Skins to players, Force select if bForceCustomChars = True
function LoadSkinsToPlayers(PlayerController PC)
{
	local int i;

	for(i=0; i < CustomSkin.Length; i++)
	{
    PC.SetPawnClass("",CustomSkin[i].SkinCode);
	}

  if(bForceCustomChars)
    {
      PC.PlayerReplicationInfo.SetCharacterName(CustomSkin[Rand(CustomSkin.Length)].SkinCode);
    }
}

defaultproperties
{
  // Mandatory Vars
	GroupName="KF-SkinsLoader"
	FriendlyName="Skins Loader - v1.0"
	Description="Load custom skins into the game without ServerPerks; Originally made by Flame, Edited by Vel-San"

	bAddToServerPackages=True
  bAlwaysRelevant=True

  // Default Config
  bForceCustomChars = False
  CustomSkin(0)=(SkinCode="KFSkinsLoader.iDoNotExist",AddDate="01.01.1945")
}
