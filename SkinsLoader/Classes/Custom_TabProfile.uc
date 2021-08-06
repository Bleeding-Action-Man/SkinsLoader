class Custom_TabProfile extends KFTab_Profile;

function bool PickModel(GUIComponent Sender)
{
	if ( Controller.OpenMenu("SkinsLoader.Custom_ModelList", PlayerRec.DefaultName, Eval(Controller.CtrlPressed, PlayerRec.Race, "")) )
	{
		Controller.ActivePage.OnClose = ModelSelectClosed;
	}

	return true;
}
