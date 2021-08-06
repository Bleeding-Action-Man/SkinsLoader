class Custom_ProfilePage extends KFProfilePage;

var automated Custom_TabProfile Custom_ProfilePanel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	local rotator PlayerRot;

	Super.InitComponent(MyController, MyOwner);

	// Set camera's pitch to zero when menu initialised (otherwise spinny weap goes kooky)
	PlayerRot = PlayerOwner().Rotation;
	SavedPitch = PlayerRot.Pitch;
	PlayerRot.Pitch = 0;
	PlayerRot.Roll = 0;
	PlayerOwner().SetRotation(PlayerRot);

	t_Footer.OnSaveButtonClicked = SaveButtonClicked;

	Custom_ProfilePanel.InitComponent(MyController, self);
	Custom_ProfilePanel.Opened(self);
	Custom_ProfilePanel.ShowPanel(true);
}

function SaveButtonClicked()
{
	Custom_ProfilePanel.SaveSettings();
	Controller.CloseMenu(False);
}

defaultproperties
{
	Begin Object class=Custom_TabProfile name=Panel
		WinWidth=0.98
		WinHeight=0.96
		WinLeft=0.01
		WinTop=0.01
	End Object
	Custom_ProfilePanel=Panel
}