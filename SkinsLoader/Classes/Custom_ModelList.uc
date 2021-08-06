class Custom_ModelList extends KFModelSelect;

// V. Important reference for base mutator class
var SkinsLoader MutRef;

// Updated "PlayerList" to support Custom Characters
function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
  super(LockedFloatingWindow).Initcomponent(MyController, MyOwner);

  sb_Main.SetPosition(0.040000,0.075000,0.680742,0.555859);
  sb_Main.RightPadding = 0.5;
  sb_Main.ManageComponent(CharList);

  // Add Custom Chars
  MutRef = class'SkinsLoader'.default.Mut;
  ParseSkinsToPlayerRecords(MutRef.aCustomSkin);

  class'xUtil'.static.GetPlayerList(PlayerList);
  RefreshCharacterList("DUP");

  // Spawn spinning character actor
  if ( SpinnyDude == None )
    SpinnyDude = PlayerOwner().spawn(class'XInterface.SpinnyWeap');

  SpinnyDude.SetDrawType(DT_Mesh);
  SpinnyDude.SetDrawScale(0.9);
  SpinnyDude.SpinRate = 0;
}

function ParseSkinsToPlayerRecords(array<string> CS)
{
  local int i;
  local xUtil.PlayerRecord PR;

  for( i=0; i<CS.Length; ++i )
  {
    // Get PlayerRecord for the skin
    PR = Class'xUtil'.Static.FindPlayerRecord(CS[i]);
    // log("Found skin of species: "$PR.Species);

    // Add this "PR" to the PlayerList
    PlayerList.Insert(0,1);
		PlayerList[0] = PR;
  }
}