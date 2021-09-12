/*
Discord bot config
Allows you to block unofficial bot to join a discord guild or not

Author: Palwa
*/
#include <a_samp>
#include <dini>
#include <discord-connector>
#include <discord-cmd>

#define BOT_CONFIG "D-Bot[Allowed].txt"

public DCC_OnGuildMemberAdd(DCC_Guild:guild, DCC_User:user)
{
	guild = DCC_FindGuildById("864803921997856780");


	new bool: bot, bool: verified, id[21], gname[40], bname[DCC_NICKNAME_SIZE], DCC_User: owner;

	DCC_IsUserBot(user, bot);
	DCC_IsUserVerified(user, verified);

	if(bot && !verified && !dini_Exists(BOT_CONFIG))
	{
		DCC_GetGuildOwnerId(guild, id, sizeof(id));
		DCC_GetGuildName(guild, gname, sizeof(gname));
		DCC_GetUserName(user, bname, sizeof(bname));

		owner = DCC_FindUserById(id);

		new string[244];
		format(string, 244, 
		"```An unofficial bot just entered your guild. We just recently kicked it to avoid any danger```\n**GUILD: %s\nBOT NAME: %s**", gname, bname);
		DCC_CreatePrivateChannel(owner, "DCC_DM", "s", string);

		DCC_RemoveGuildMember(guild, user);
	}
	return 1;
}

DCMD:dbot(user, channel, params[])
{
	new DCC_Guild: guild, id[21], uid[21];

	DCC_GetChannelGuild(channel, guild);

	DCC_GetGuildOwnerId(guild, id, sizeof(id));
	DCC_GetUserId(user, uid, sizeof(id));

	if(strval(id) != strval(uid)) return DCC_SendChannelMessage(channel, "```Only server owner allowed to use this command```");

	if(!strlen(params)) return DCC_SendChannelMessage(channel, "```!dbot [enable/disable]```");

	if(!strcmp(params, "enable"))
	{
		DCC_SendChannelMessage(channel, "```Succesfully allowed unofficial bot access, remember this action may harmful```");
		dini_Create(BOT_CONFIG);
	}
	else if(!strcmp(params, "disable"))
	{
		dini_Remove(BOT_CONFIG);

		DCC_SendChannelMessage(channel, "```Succesfully blocked unofficial bot access, your guild may safe for now```");
	}
	else return DCC_SendChannelMessage(channel, "```!dbot [enable/disable]```");
	return 1;
}

forward DCC_DM(str[]);
public DCC_DM(str[])
{
    new DCC_Channel:PM;
	PM = DCC_GetCreatedPrivateChannel();
	DCC_SendChannelMessage(PM, str);
	return 1;
}