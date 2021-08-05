//////////////////////////////////////////////
// Load custom skins without ServerPerks
// Originally made by Flame, Edited by Vel-San
// TODO: Unlock DLC Skins (?)
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

// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var() config array<ColorRecord> ColorList; // Color list

// Mut Vars
var transient array<name> AddedServerPackages;
var array<PlayerController> PendingPlayers;
var array<string> aCustomSkin;

// V. Important Pointer to Self
var SkinsLoader Mut;

replication
{
  unreliable if (Role == ROLE_Authority)
                  aCustomSkin;
}

function PreBeginPlay()
{
  if (Level.NetMode != NM_Client)
  {
    // Critical: Force clients to download the skins packages
    if(bAddAsServerPackages) AddSkinsToServer();
    // Add the skins to the server
    AddCustomSkins();
  }
}

simulated function PostBeginPlay()
{
  // Local Vars
  local int i;

  // Pointer To self
  Mut = self;
  default.Mut = self;
  class'SkinsLoader'.default.Mut = self;

  // Fill in the Dynamic Array of Special Players
  for(i=0; i<CustomSkin.Length; i=i++)
  {
    aCustomSkin[i] = CustomSkin[i].sSkinCode;
  }

  // ParseSkinsToPlayerRecords(aCustomSkin);
}

/*function ParseSkinsToPlayerRecords(array<string> CS)
{
  local int i;
  local xUtil.PlayerRecord PR;

  for( i=0; i<CS.Length; ++i )
  {
      PR = Class'xUtil'.Static.FindPlayerRecord(CS[i]);
      MutLog("-----|| PlayerRecord SPECIES [" $PR.Species$ "] ||-----");
      MutLog("-----|| PlayerRecord TEXT NAME [" $PR.TextName$ "] ||-----");

      // if( PR.DefaultName~=C )
      // {
      //     ++CustomOffset;
      //     PlayerList.Insert(0,1);
      //     PlayerList[0] = PR;
      // }
  }
}*/

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

  MutLog("-----|| Found [" $CustomSkin.Length$ "] Skins in Config ||-----");
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

  PendingPlayers.Remove(0, 1);
}

simulated function Tick(float DeltaTime) {
  local PlayerController localController;

  MutLog("-----|| Injecting Skin Loader's 'Custom Model List' ||-----");

  localController= Level.GetLocalPlayerController();
  if (localController != none) {
      localController.Player.InteractionMaster.AddInteraction("SkinsLoader.CustomInteraction", localController.Player);
  }
  Disable('Tick');
}

// Load all Skins to players, Force select if bForceCustomChars = True
function ForceSkins(PlayerController PC)
{
  if(bForceCustomChars) PC.PlayerReplicationInfo.SetCharacterName(CustomSkin[Rand(CustomSkin.Length)].sSkinCode);
}

function bool UseSkin(int index, string PlayerName, PlayerController PC)
{
  local int i;
  local string SuccessMSG, FailedMSG;

  SuccessMSG = "%bSkin %gSuccessfully%w Applied!";
  FailedMSG = "%bSkin %rSFailed%w to apply! Retry & check the skin index.";

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
  local int i;
  local string SkinEntry;

  for(i=0; i < CustomSkin.Length; i++)
  {
    SkinEntry = "%bDesc.: %t" $CustomSkin[i].sSkinDescription$ "%w | ID: %y" $CustomSkin[i].iSkinID$ "%w | Added at: %o" $CustomSkin[i].sAddDate;
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

  if(command ~= sPrintSkinsCMD)
  {
    PrintAllSkins(Sender);
  }

  if(Left(command, Len(sUseSkinCMD)) ~= sUseSkinCMD)
  {
    UseSkin(int(SplitCMD[1]), PN, Sender);
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
  FriendlyName="Skins Loader - v2.0"
  Description="Load custom skins into the game without ServerPerks; Written by Vel-San, Flame & Marco"

  bAddToServerPackages = true
  RemoteRole = ROLE_SimulatedProxy
  bAlwaysRelevant = true
  bNetNotify=true
}
