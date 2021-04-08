trigger AccountTrigger on Account ( after insert, after update) {
	new LPAN_AccountTriggerHandler().run();
}