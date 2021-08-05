// Thanks to ScaryGhost for his Interaction Class code reference

class CustomInteraction extends Interaction;

event NotifyLevelChange() {
  Master.RemoveInteraction(self);
}

function Tick (float DeltaTime) {
  local KFGUIController guiController;

  guiController= KFGUIController(ViewportOwner.GUIController);
  if (guiController != none && guiController.ActivePage != none && 
      ClassIsChildOf(guiController.ActivePage.class, class'KFGui.KFModelSelect')) {
    ViewportOwner.Actor.ClientCloseMenu(true, true);
    KFPlayerController(ViewportOwner.Actor).ClientOpenMenu("SkinsLoader.Custom_ModelList");
  }
}