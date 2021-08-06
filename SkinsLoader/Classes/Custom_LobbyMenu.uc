class Custom_LobbyMenu extends LobbyMenu;

function bool ShowPerkMenu(GUIComponent Sender)
{
	if ( PlayerOwner() != none)
	{
		PlayerOwner().ClientOpenMenu("SkinsLoader.Custom_ProfilePage", false);
	}

	return true;
}

function OnSteamStatsAndAchievementsReady()
{
	Controller.OpenMenu("SkinsLoader.Custom_ProfilePage");

	Controller.OpenMenu(Controller.QuestionMenuClass);
	GUIQuestionPage(Controller.TopPage()).SetupQuestion(SelectPerkInformationString, QBTN_Ok, QBTN_Ok);
}