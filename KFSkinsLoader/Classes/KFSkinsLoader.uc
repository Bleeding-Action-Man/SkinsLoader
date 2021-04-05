//////////////////////////////////////////////
// Load custom skins without ServerPerks
// Originally made by Flame, Edited by Vel-San
//////////////////////////////////////////////

class SkinsLoader extends Mutator Config(SkinsLoader_Config);

struct Skin
{
  var config string sSkinCode;
  var config string sSkinDescription;
  var config int iSkinID;
  var config string sAddDate;
};

// Config Var for SkinsList
var config array<Skin> CustomSkin;
var config float fReplacementTimer;
var config bool bForceCustomChars, bAddAsServerPackages;
var config string sUseSkinCMD, sPrintSkinsCMD;

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
  // SaveConfig();
}

// Add Skins to AvailableChars list
function bool AddCustomSkins()
{
  local int i, j;

  for(i=0;i<CustomSkin.Length;i++)
  {
  j = KFGameType(Level.Game).AvailableChars.Length;
  if(!SkinAlreadyAdded(CustomSkin[i].sSkinCode)) KFGameType(Level.Game).AvailableChars[j] = CustomSkin[i].sSkinCode;
  }
  return true;
}

// Add Skins to server as ServerPackages
function AddSkinsToServer()
{
  local int i;
  local array<string> PackageName;

  MutLog("-----|| Found [" $CustomSkin.Length$ "] Skins in Config||-----");
  for( i=0; i<CustomSkin.Length; ++i )
  {
  SplitStringToArray(PackageName, CustomSkin[i].sSkinCode, ".");
  AddToPackageMap(PackageName[0]);
  MutLog("-----|| Skin [" $PackageName[0]$ "] Added to ServerPackages ||-----");
  }
}

// Check is Skin is already added
function bool SkinAlreadyAdded(string sSkinCode)
{
  local int i;
  for(i=0;i<KFGameType(Level.Game).AvailableChars.Length;i++)
  {
  if(KFGameType(Level.Game).AvailableChars[i] ~= sSkinCode) return true;
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
  PC.SetPawnClass("", CustomSkin[i].sSkinCode);
  }*/

  if(bForceCustomChars) PC.PlayerReplicationInfo.SetCharacterName(CustomSkin[Rand(CustomSkin.Length)].sSkinCode);
}

function bool UseSkin(int index, string PlayerName, PlayerController PC)
{
  local int i;
  local string SuccessMSG, FailedMSG;

  SuccessMSG = "Skin %gSuccessfully%w Applied!";
  FailedMSG = "Skin %rSFailed%w to apply! Retry & check the skin index.";

  for(i=0; i < CustomSkin.Length; i++)
  {
  if(CustomSkin[i].iSkinID == index)
    {
      MutLog("-----|| " $PlayerName$ " Applied skin of index: " $index$ " ||-----");
      PC.PlayerReplicationInfo.SetCharacterName(CustomSkin[i].sSkinCode);
      SetColor(SuccessMSG);
      PC.ClientMessage(SuccessMSG);
      return true;
    }
  }

  SetColor(FailedMSG);
  PC.ClientMessage(FailedMSG);
  return false;
}

function PrintAllSkins(PlayerController PC)
{
  local string SkinEntry;

  for(i=0; i < CustomSkin.Length; i++)
  {
    SkinEntry = "Desc.: %b" $CustomSkin[i].sSkinDescription$ "%w ID: %y" $CustomSkin[i].iSkinID$ "%w Added at: %o" $CustomSkin[i].sAddDate;
    SetColor(SkinEntry);
    PC.ClientMessage(SkinEntry);
  }
}

function Mutate(string command, PlayerController Sender)
{
  local string PN, PID, WelcomeMSG, TotalSkins, UsageMSG, PrintSkins;
  local array<string> SplitCMD;

  PN = Sender.PlayerReplicationInfo.PlayerName;
  PID = Sender.GetPlayerIDHash();

  MutLog("-----|| '" $command$ "' accessed by: " $PN$ " | PID: " $PID$  " ||-----");

  SplitStringToArray(SplitCMD, command, " ");

  if(command ~= "sl help" || command ~= "skinsloader help")
  {
    WelcomeMSG = "%yYou are viewing Skins-Loader Help, below are the commands you can use";
    TotalSkins = "%bTotal Skins: %w" $CustomSkin.Length;
    UsageMSG = "%bUsage: %wmutate " $sUseSkinCMD$ " %tXXX%w | XXX is the 'ID'";
    PrintSkins = "%bTo view all available skins: %wmutate %t" $sPrintSkinsCMD;

    SetColor(WelcomeMSG);
    SetColor(TotalSkins);
    SetColor(UsageMSG);
    SetColor(PrintSkins);

    Sender.ClientMessage(WelcomeMSG);
    Sender.ClientMessage(TotalSkins);
    Sender.ClientMessage(UsageMSG);
    Sender.ClientMessage(PrintSkins);

    return;
  }

  if(command ~= "!skins" )
  {
    PrintAllSkins(Sender);
  }

  if(Left(command, Len(sPlaySoundCMD)) ~= sUseSkinCMD)
  {
    UseSkin(SplitCMD[1], PN, Sender);
  }

  if (NextMutator != None ) NextMutator.Mutate(command, Sender);
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

/////////////////////////////////////////////////////////////////////////
// BELOW SECTION IS CREDITED FOR NikC //

// Apply Color Tags To Message
function SetColor(out string Msg)
{
  local int i;
  for(i=0; i<ColorList.Length; i++)
  {
  if(ColorList[i].ColorTag!="" && InStr(Msg, ColorList[i].ColorTag)!=-1)
  {
  ReplaceText(Msg, ColorList[i].ColorTag, FormatTagToColorCode(ColorList[i].ColorTag, ColorList[i].Color));
  }
  }
}

// Format Color Tag to ColorCode
function string FormatTagToColorCode(string Tag, Color Clr)
{
  Tag=Class'GameInfo'.Static.MakeColorCode(Clr);
  Return Tag;
}

function string RemoveColor(string S)
{
  local int P;
  P=InStr(S,Chr(27));
  While(P>=0)
  {
  S=Left(S,P)$Mid(S,P+4);
  P=InStr(S,Chr(27));
  }
  Return S;
}
//////////////////////////////////////////////////////////////////////

defaultproperties
{
  // Mandatory Vars
  GroupName="KF-SkinsLoader"
  FriendlyName="Skins Loader - v1.0"
  Description="Load custom skins into the game without ServerPerks; Originally made by Flame, Edited by Vel-San"
  // bAddAsServerPackages = True
}
