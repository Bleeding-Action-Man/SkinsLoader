// Thanks to ScaryGhost for his Interaction Class code reference

class CustomInteraction extends Interaction;

var string lobbyMenuClass;

event NotifyLevelChange() {
  Master.RemoveInteraction(self);
}

function Tick (float DeltaTime) {
  local KFGUIController guiController;

  guiController= KFGUIController(ViewportOwner.GUIController);
  if (guiController != none && guiController.ActivePage != none && 
      ClassIsChildOf(guiController.ActivePage.class, class'KFGui.LobbyMenu')) {
    KFPlayerController(ViewportOwner.Actor).LobbyMenuClassString=lobbyMenuClass;
    ViewportOwner.Actor.ClientCloseMenu(true, true);
    KFPlayerController(ViewportOwner.Actor).ShowLobbyMenu();

    bRequiresTick = false;
  }
}

defaultproperties {
  bRequiresTick=true

  lobbyMenuClass="SkinsLoader.Custom_LobbyMenu"
}