#include <a_samp>
#include <streamer>
#include <a_mysql>
#include <foreach>
#include <sscanf2>
#include <Pawn.CMD>
#include <weapon>
//#include <sv-weap>
#include <stringedit>
#include <3DTryg>
#pragma tabsize 0

#define UUID_LEN (37)
native UUID(result[], len = sizeof result);


#define SERVER_HOSTNAME "CSGO"
#define SERVER_GAMETEXT "CSGO"
#define SERVER_MAPNAME "CSGO"
#define SERVER_WEBURL "www.sa-mp.com"
#define SERVER_LANGUAGE "��/English"
#define SERVER_OWNER "WDTK"

#define MYSQL_HOST "127.0.0.1"
#define MYSQL_USER " "
#define MYSQL_PASS " "
#define MYSQL_DB   "csgo"
#define MYSQL_DB_USER "�û�"
#define MYSQL_DB_USER_INV "����"

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))
#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))


new User@Handle;
new string256[256];
#define formatex256( string256="";format(string256,sizeof(string256),
new string128[128];
#define formatex128( string128="";format(string128,sizeof(string128),
new string80[80];
#define formatex80( string80="";format(string80,sizeof(string80),
new string64[64];
#define formatex64( string64="";format(string64,sizeof(string64),
new string32[32];
#define formatex32( string32="";format(string32,sizeof(string32),
#define SCM SendClientMessage

#define N::%1(%3) forward %1(%3);  public %1(%3)
#define NONE  -1
#define forex(%0,%1) for(new %0 = 0; %0 < %1; %0++)
#define loop(%0,%1,%2) for(new %0 = %1; %0 < %2; %0++)
#define Hooks CallRemoteFunction
#define PASSWORD_SALT   "csgo8866"
#define Timer: _@timer_

#define PLAYER_INTFACE_WORLD 1000
//new Timer#SecondUpdate=NONE;
/******************************************************************************/
enum Account_InFo//������� 
{
	_Index,
	_Key[64],
	_Name[64],
	_Password[128],
	_Skin@Avatar,
	_Cash,
	_Mute,
	_Level,
	_Exp,
	bool:_Login,
	bool:_Register,
	Timer:_SpawnTimer,
	Timer:_ShowTimer,
	Float:_FaceAngle
};
new Account[MAX_PLAYERS][Account_InFo];
/******************************************************************************/
enum
{
    STATE_NULL,
    STATE_COMP_SELECT,
	STATE_SPEC,
	STATE_PLAYING,
	STATE_DEATH_SPEC
}
enum
{
    TEAM_NULL,
    TEAM_COP,
    TEAM_TER
}
enum PlayerGameRoom_InFo
{
	_GameID,
	_State,
	_Team,
	_Score,
	_Money,
	Float:_BodyArmor,
	Float:_ShieldArmor,
	Timer:_FreezeTimer
}
new PlayerGameRoom[MAX_PLAYERS][PlayerGameRoom_InFo];
#define MAX_PLAYER_WEAPONS 3
enum PlayerGameWeapon_InFo
{
	_WeaponID[MAX_PLAYER_WEAPONS],
	_WeaponAmmo[MAX_PLAYER_WEAPONS]
}
new PlayerGameWeapon[MAX_PLAYERS][PlayerGameWeapon_InFo];
#define GAMEWORLD_LIMIT MAX_PLAYERS
#define GameRoomWorld(%0) GAMEWORLD_LIMIT+%0
#define MAX_GAMEROOMS 20//��Ϸ��������
#define SYSTEM_OWNER -255
#define SYSTEM_NULL -256
enum GameRoom_InFo
{
	_GameKey[64],
	_MapID,
	_Mode,
	_OwnerKey[37],
	_MaxPlayers,
	bool:_Lock,
	_Password[32],

	_CurrentRoundTime,
	_MaxRoundTime,
	
	_CurrentRoundMap,
	_MaxRoundMap,
	
	_BuyGunTime,
	_MaxBuyGunTime,

	_C4Time,
	_MaxC4Time,
	
	_MaxFreezeTime,
	
	_StartMoney,
	
	bool:_TeamHit,
	bool:_FallHit,
	bool:_KickAfk
	
}
new GameRoom[MAX_GAMEROOMS][GameRoom_InFo];
new Iterator:GameRoom<MAX_GAMEROOMS>;
#define MAX_GAMEROOMPLAYERS 15
enum GameRoomTeamTag_InFo
{
	_Cop_ID[MAX_GAMEROOMPLAYERS],
	_Ter_ID[MAX_GAMEROOMPLAYERS],
	Text:_LastTime,
	Text:_Cop_Score,
	Text:_Ter_Score,
	Text:_Cop_ID_Avatar[MAX_GAMEROOMPLAYERS],
	Text:_Ter_ID_Avatar[MAX_GAMEROOMPLAYERS],
	Text:_Cop_ID_ID[MAX_GAMEROOMPLAYERS],
	Text:_Ter_ID_ID[MAX_GAMEROOMPLAYERS]
}
new GameRoomTeamTag[MAX_GAMEROOMS][GameRoomTeamTag_InFo];
#define MAX_GAMEROOMTAGDRAWS 3
new Text:GameRoomTagDraw[MAX_GAMEROOMTAGDRAWS]= {Text:INVALID_TEXT_DRAW, ...};

enum GameMode_Info//��Ϸģʽ
{
    _Name[32],
    _Mod@Name
}
new GameMode[][GameMode_Info] =
{
    {"��ͨ��",-2089}
};

enum GameMaxPlayer_Info//��Ϸ�������
{
    _Amount
}
new GameMaxPlayer[][GameMaxPlayer_Info] =
{
    {10},
    {12},
    {14},
    {16},
    {18},
    {20},
    {22},
    {24},
    {26},
    {28},
    {30}
};
enum Map_Info//��Ϸ��ͼ����
{
    _Name[32],
    _Mod@Name,
    _Mod@Avatar,
    Float:_Cop_SpawnX,
    Float:_Cop_SpawnY,
    Float:_Cop_SpawnZ,
    Float:_Ter_SpawnX,
    Float:_Ter_SpawnY,
    Float:_Ter_SpawnZ
}
new Map[][Map_Info] =
{
    {"��װ��",-2076,-2007,8072.1938,-7590.0269,15.3666,8167.7632,-7539.1250,15.3666},
    {"�ű�",-2077,-2035,9433.0000,-8785.9131,30.3850,9580.1826,-8763.8047,23.0410},
    {"��վ",-2078,-2036,-4404.7939,-6756.4443,17.5719,-4180.0898,-6782.3784,11.9720},
    {"ɳĮ1",-2079,-2036,1067.0435,-3847.5522,10.6155,1059.6620,-3753.0547,9.2173},
    {"ɳĮ2",-2080,-2036,7698.5835,-2647.4639,18.4302,7743.2515,-2567.6052,18.4135},
    {"ѩ��",-2081,-2036,1531.2164,-8773.7920,9.9638,1565.0527,-8840.2539,9.9582},
    {"�����1",-2082,-2036,665.6163,-2326.6270,107.5576,681.7640,-2399.4373,107.2728},
    {"�����2",-2083,-2036,1141.2037,-3754.0291,4.6119,1188.7896,-3846.9490,7.2464}
};
#define MAX_MAPOBJS 300//���ص�ͼ����
new GameRoomMapObjects[MAX_GAMEROOMS][MAX_MAPOBJS];
new Iterator:GameRoomMapObjects[MAX_GAMEROOMS]<MAX_MAPOBJS>;
/******************************************************************************/
enum
{
    RETURN_UNKONW_ERROR,
	RETURN_SUCCESS,
	RETURN_DATA_FULL,
	RETURN_NOT_EXIST
}
#define MAX_PLAYERGLOBALINV_LIMIT 10
#define MAX_PLAYERGLOBALINV_SLOTS 100
enum PlayerGlobalInv_InFo
{
	_AccountKey[37],
	_InvKey[37],
	_ItemKey[37],
	_Amounts/*,
	_Temp@Type*/
};
new PlayerGlobalInv[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SLOTS][PlayerGlobalInv_InFo];
new Iterator:PlayerGlobalInv[MAX_PLAYERS]<MAX_PLAYERGLOBALINV_SLOTS>;
/************************************************************///�����б�
#define MAX_PLAYRTGLOBALINVBACKTEXTDRAWS 9
new Text:PlayerGlobalInvBackTextDraw[MAX_PLAYRTGLOBALINVBACKTEXTDRAWS];

#define MAX_PLAYERGLOBALINV_BOX_ITEMS MAX_PLAYERGLOBALINV_SLOTS+2
#define MAX_PLAYERGLOBALINV_SHOW_LIST 6
new PlayerGlobalInvPrevieBox[MAX_PLAYERS][MAX_PLAYERGLOBALINV_BOX_ITEMS];
new PlayerGlobalInvPrevieBoxKey[MAX_PLAYERS][MAX_PLAYERGLOBALINV_BOX_ITEMS][64];
new PlayerGlobalInvPrevieBoxDrawID[MAX_PLAYERS][MAX_PLAYERGLOBALINV_BOX_ITEMS];
new PlayerGlobalInvPrevieCount[MAX_PLAYERS];
new PlayerGlobalInvPreviePage[MAX_PLAYERS];
new PlayerGlobalInvPrevieRate[MAX_PLAYERS];
new PlayerGlobalInvClickID[MAX_PLAYERS];


new PlayerText:PlayerGlobalInvListBg[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SHOW_LIST];//�б���
new PlayerText:PlayerGlobalInvListModel[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SHOW_LIST];//�б���Ʒģ��Ԥ��
new PlayerText:PlayerGlobalInvListType[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SHOW_LIST];//�б���Ʒ����
new PlayerText:PlayerGlobalInvListTypeName[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SHOW_LIST];//�б���Ʒ��������
new PlayerText:PlayerGlobalInvListAT[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SHOW_LIST];//�б���Ʒ��������
new PlayerText:PlayerGlobalInvListAmount[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SHOW_LIST];//�б���Ʒ����
new PlayerText:PlayerGlobalInvListName[MAX_PLAYERS][MAX_PLAYERGLOBALINV_SHOW_LIST];//�б���Ʒ����

new PlayerText:PlayerGlobalInvSlider[MAX_PLAYERS];//�б������
new PlayerText:PlayerGlobalInvLimit[MAX_PLAYERS];//��ҿɳ��������


new bool:PlayerGlobalInvListShow[MAX_PLAYERS];//�б��Ƿ���ʾ
/************************************************************/
#define MAX_DOWNLOADTEXTDRAWS 2
new Text:DownLoadTextDraw[MAX_DOWNLOADTEXTDRAWS];
new PlayerText:PlayerDownLoadSign[MAX_PLAYERS];
new PlayerText:PlayerDownLoadProgress[MAX_PLAYERS];
new PlayerDownLoadSignRate[MAX_PLAYERS];
/************************************************************/
enum Skins_Info//Ƥ�� ͷ��
{
    _Mod@Skin,
    _Mod@Avatar
}
new Skins[][Skins_Info] =
{
    {0,-2040},
    {20004,-2006},
    {20001,-2005},
    {20002,-2009},
    {20003,-2031}

};
#define MAX_ITEMS 100
enum
{
    ITEM_TYPE_NONE,
	ITEM_TYPE_SKIN,
	ITEM_TYPE_ATTACH,
	ITEM_TYPE_FUNC
}
enum ItemTypes_Info
{
    _Name[16],
    _Model
}
new ItemTypes[][ItemTypes_Info] =
{
    {"��Ч",0},
    {"Ƥ��",-2047},
    {"װ��",-2051},
    {"����",-2051}

};
enum Item_Info
{
	_Key[37],
	_Type,
	_Index,
	_Model,
	_Price,
	_Stock,
	_Name[32],
	_NameModel
}
new Item[][Item_Info] =
{
	{"911a40ef-d74b-4a83-b74b-7f71f9841dde",ITEM_TYPE_SKIN,1,ITEM_TYPE_NONE,1,16,"�����ܱ�����",-2059},
	{"07892f3f-cefb-4b11-8345-b276d58d76ff",ITEM_TYPE_SKIN,2,ITEM_TYPE_NONE,2,15,"��ŷ��Ӷ��",-2060},
	{"b7d80e24-f496-4333-8bf6-49b24989543d",ITEM_TYPE_SKIN,3,ITEM_TYPE_NONE,3,14,"�����˹����",-2061},
	{"cb636990-af45-4fd2-8d80-81bfbb43b6cb",ITEM_TYPE_SKIN,4,ITEM_TYPE_NONE,4,13,"�����ػ���",-2062}

/*	{"41e32d4c-7e46-47a5-bf57-c6d7a5417b55",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"edb8bfbf-88ec-4a44-8701-0d01cd624f85",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"baf05bc1-47b5-423e-8429-a30961097a37",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"75436ba3-78ef-4487-bec9-cb93a669d8c4",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"f180e321-5697-48cc-9280-38503ac8b20d",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"2e6685bc-6da4-4fc2-a2e7-554e1e365caa",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"fb34e1dd-4913-4295-92e2-d050f411fa7c",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"144b7447-2325-4b7f-acb4-59a0bbff60f2",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"030621e2-6737-47a3-b170-445b58e48ee3",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"259f7d5d-a1da-47ce-8f87-4c8f88de1b05",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"3bd18823-3e78-4c6b-b532-2d4d6e059345",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE},
	{"33eebbbe-d891-48c5-862c-e6b5fec6d9d4",ITEM_TYPE_OTHER,-1,ITEM_TYPE_NONE}
	{"29f43877-b41f-4b7b-b362-5040badca35f",ITEM_TYPE_NONE,-1},
	{"45647fa5-ba89-45ad-aaca-23cc78a7bf08",ITEM_TYPE_NONE,-1},
	{"75f07b0b-a160-41c4-8b83-531e647f15c2",ITEM_TYPE_NONE,-1},
	{"ffde78fe-a639-47ff-8a7c-5cf159561c34",ITEM_TYPE_NONE,-1},
	{"57d3df57-efa6-4a32-a89b-345db2366241",ITEM_TYPE_NONE,-1},
	{"c4f1efa3-6b92-4620-bc7b-849c5d01ba48",ITEM_TYPE_NONE,-1},
	{"74c0b6ed-6cc9-4a98-8a43-3cba6f2fdb9c",ITEM_TYPE_NONE,-1},
	{"3877f094-a1a7-4835-a3e2-801c35264a61",ITEM_TYPE_NONE,-1},
	{"3860be08-df27-4ed9-80b7-2de652bcb377",ITEM_TYPE_NONE,-1},
	{"9171826e-b806-43f2-b5fa-eabe438db356",ITEM_TYPE_NONE,-1},
	{"5257fd39-450f-4d06-93f2-9ef802c1b071",ITEM_TYPE_NONE,-1},
	{"c6f7e708-86a9-4f22-a376-43e5c2b9516f",ITEM_TYPE_NONE,-1},
	{"05f6f5e3-cb07-4247-becb-535bda9d6e18",ITEM_TYPE_NONE,-1},
	{"e549af9a-d9da-4d01-893d-06ffd84688bf",ITEM_TYPE_NONE,-1},
	{"e35d8c2f-a322-4f7b-be4a-bf24f84e871e",ITEM_TYPE_NONE,-1},
	{"b1dba271-171e-419e-866d-38579cbabc49",ITEM_TYPE_NONE,-1},
	{"66e2fd56-a2ce-4d00-8ee9-56334ee5ce4c",ITEM_TYPE_NONE,-1},
	{"b73221c7-82ed-480b-967c-d27d34319079",ITEM_TYPE_NONE,-1},
	{"8bfa48e9-3472-4db7-9dfe-f841bd5a14fe",ITEM_TYPE_NONE,-1},
	{"45099481-66bf-47ff-a27b-7c966cfa8acd",ITEM_TYPE_NONE,-1},
	{"5868015e-60f7-40fa-b6df-a5b1e5ff9e74",ITEM_TYPE_NONE,-1},
	{"9c2dfb75-2181-4724-9213-be33d1b22f44",ITEM_TYPE_NONE,-1},
	{"3096874e-0220-4033-971a-5193bf5fc10a",ITEM_TYPE_NONE,-1},
	{"36366169-0c6d-47c7-9f6e-1d953158337e",ITEM_TYPE_NONE,-1},
	{"999b48ed-c7b7-4136-88d5-cca158bd3054",ITEM_TYPE_NONE,-1},
	{"9919856b-6b28-46e1-8246-522301ba9bf4",ITEM_TYPE_NONE,-1},
	{"a209f3e8-bc10-4923-8b67-ffe8517ecd0f",ITEM_TYPE_NONE,-1},
	{"ea8960d2-7eff-4733-b206-96f21d61a7bf",ITEM_TYPE_NONE,-1},
	{"d8b93006-d655-4e40-995c-6f2fe47d258d",ITEM_TYPE_NONE,-1},
	{"79befc13-3448-42f0-a58a-cad47fdbe72b",ITEM_TYPE_NONE,-1},
	{"d2955731-e366-4cbe-80fd-b1b476a7d1ee",ITEM_TYPE_NONE,-1},
	{"de324f7a-1ad2-4bce-9fd3-3b259189fc59",ITEM_TYPE_NONE,-1},
	{"7fb3e9de-1be3-4f13-b64d-21159e494b11",ITEM_TYPE_NONE,-1},
	{"44ddb2b3-89e4-4417-a371-06d8d6d2e292",ITEM_TYPE_NONE,-1},
	{"a8474aef-5d45-4779-9224-fcfb33732954",ITEM_TYPE_NONE,-1},
	{"16f98491-6ce8-4562-a93b-616649c9da16",ITEM_TYPE_NONE,-1},
	{"74b8feb5-b52d-423f-9474-1ed178a9777b",ITEM_TYPE_NONE,-1},
	{"311621ab-ac53-4436-8ce2-11932f48fa50",ITEM_TYPE_NONE,-1},
	{"8de8d920-4147-43ea-a454-a862c16bdb96",ITEM_TYPE_NONE,-1},
	{"19c0ea5b-8264-4bc6-b62d-1748411d412c",ITEM_TYPE_NONE,-1},
	{"f878aba4-4f82-443b-af81-c828ad204b4b",ITEM_TYPE_NONE,-1},
	{"fa846819-016e-4bad-9c12-b233f22ce776",ITEM_TYPE_NONE,-1},
	{"1366fad0-9bf8-4737-bbec-81d197ebee6c",ITEM_TYPE_NONE,-1},
	{"828fc4f0-041d-4072-af5c-1da3bd2388cf",ITEM_TYPE_NONE,-1},
	{"214d2b30-0fe5-4e40-bdbd-37b73be865c4",ITEM_TYPE_NONE,-1},
	{"260cd6ac-aa58-456d-b142-b6da18e3d2ac",ITEM_TYPE_NONE,-1},
	{"ca657d3d-d777-414a-afc6-14860f16dcbf",ITEM_TYPE_NONE,-1},
	{"b69bcdd8-3e08-447f-8e9c-c604f25e08a7",ITEM_TYPE_NONE,-1},
	{"223ac2c0-8931-4570-96e0-ff61d4bfde53",ITEM_TYPE_NONE,-1},
	{"ab9a5992-3c19-4474-a6df-794f737bb2cd",ITEM_TYPE_NONE,-1},
	{"473551a4-6557-4f5b-b759-f922bdc36e84",ITEM_TYPE_NONE,-1},
	{"04fd2b09-f93d-4993-b9af-782f4bb9cde0",ITEM_TYPE_NONE,-1},
	{"e830e8d6-c902-402c-b5e1-fb539651d32f",ITEM_TYPE_NONE,-1},
	{"7b08477f-ec27-459d-b875-b188400faa18",ITEM_TYPE_NONE,-1},
	{"d8d85a79-b344-4923-9875-0ec28e410c71",ITEM_TYPE_NONE,-1},
	{"35b7ec0e-1385-4b47-ae61-81faa34d9270",ITEM_TYPE_NONE,-1},
	{"2e9fbe3d-3022-497e-8455-a118c4ac66ad",ITEM_TYPE_NONE,-1},
	{"ea84daa1-7730-4be1-b304-916f1595e915",ITEM_TYPE_NONE,-1},
	{"5301b0e8-e6e7-436b-a36f-960e9beb50a9",ITEM_TYPE_NONE,-1},
	{"4cbb9f5a-870c-4833-9c35-deecea983f1d",ITEM_TYPE_NONE,-1},
	{"fd5840c0-bb9f-4cbe-9fa1-b29d985cfb4d",ITEM_TYPE_NONE,-1},
	{"ee293b3a-2a6d-47ad-9571-d5f34a9c47c2",ITEM_TYPE_NONE,-1},
	{"a3d55d03-41bc-4cfe-9f18-4930f68bce30",ITEM_TYPE_NONE,-1},
	{"87c98320-1b53-457e-822e-b905a39a0d72",ITEM_TYPE_NONE,-1},
	{"2b81c387-453f-44ce-a33e-f7981c907eec",ITEM_TYPE_NONE,-1},
	{"d2145cda-35b6-4621-96ba-d80e76c3eee9",ITEM_TYPE_NONE,-1},
	{"89da3095-d475-4c60-86af-d0f9ce7bfb68",ITEM_TYPE_NONE,-1},
	{"92c12da4-0e14-495f-b180-a5ff5d5ec604",ITEM_TYPE_NONE,-1},
	{"e9cda199-9e7f-4a3f-8779-41bc181d728f",ITEM_TYPE_NONE,-1},
	{"c29848e0-d66f-4065-8e5c-2c2eb148aa73",ITEM_TYPE_NONE,-1},
	{"b475e9c6-78bc-4d5c-b392-afa0a7d7aadb",ITEM_TYPE_NONE,-1},
	{"235744bc-af0c-4b28-9a4c-924784be8351",ITEM_TYPE_NONE,-1},
	{"a930558f-ecc7-453c-912e-436052a8406e",ITEM_TYPE_NONE,-1},
	{"a9c6251d-8ae7-476a-b278-6d82f36284d7",ITEM_TYPE_NONE,-1},
	{"71e1ad6a-690f-4a29-978e-7fec6a91160e",ITEM_TYPE_NONE,-1},
	{"10498bd2-4489-49d6-9b73-c5cef617d398",ITEM_TYPE_NONE,-1},
	{"6894689b-4b1d-4dc8-b69f-d57057ba54b3",ITEM_TYPE_NONE,-1},
	{"13c34dc6-6b73-493d-9d5f-cac249de8d45",ITEM_TYPE_NONE,-1},
	{"5134c10f-e356-422d-b701-24dadb760bcc",ITEM_TYPE_NONE,-1},
	{"71935cf1-b60e-4eb6-bf36-e5df7fc82c65",ITEM_TYPE_NONE,-1},
	{"3cb237c1-a8b9-420d-8954-250703b9481a",ITEM_TYPE_NONE,-1},
	{"c25f4124-8f93-40a6-bf85-39a51475d03e",ITEM_TYPE_NONE,-1},
	{"fb29f536-b3b3-46e0-8167-d8b731db6b5b",ITEM_TYPE_NONE,-1},
	{"1baf53a6-1d3f-40e7-8a50-9b35392872d3",ITEM_TYPE_NONE,-1}*/
};
/************************************************************///Ƥ���̵��б�
#define MAX_SHOPTEXTDRAWS 14
new Text:ShopBackTextDraw[MAX_SHOPTEXTDRAWS];
enum
{
    SHOP_TYPE_ALL,
	SHOP_TYPE_SKIN,
	SHOP_TYPE_ATTACH,
	SHOP_TYPE_FUNC
}

#define MAX_SHOP_BOX_ITEMS MAX_ITEMS+2
#define MAX_SHOP_SHOW_LIST 16

new PlayerShopPrevieBox[MAX_PLAYERS][MAX_SHOP_BOX_ITEMS];
new PlayerShopPrevieBoxKey[MAX_PLAYERS][MAX_SHOP_BOX_ITEMS][64];
new PlayerShopPrevieBoxDrawID[MAX_PLAYERS][MAX_SHOP_BOX_ITEMS];
new PlayerShopItemAmounts[MAX_PLAYERS][MAX_SHOP_BOX_ITEMS];
new PlayerShopPrevieCount[MAX_PLAYERS];
new PlayerShopPreviePage[MAX_PLAYERS];
new PlayerShopPrevieRate[MAX_PLAYERS];
new PlayerShopClickID[MAX_PLAYERS];
new PlayerShopType[MAX_PLAYERS];



new PlayerText:PlayerShopListBg[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б���
new PlayerText:PlayerShopListModel[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б�ģ��
new PlayerText:PlayerShopListPriceText[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б�۸�����
new PlayerText:PlayerShopListStockText[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б�������
new PlayerText:PlayerShopListJia[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б���-
new PlayerText:PlayerShopListJiaBack[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б���-
new PlayerText:PlayerShopListJian[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б���+
new PlayerText:PlayerShopListJianBack[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б���-
new PlayerText:PlayerShopListBuyAmount[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б�������
new PlayerText:PlayerShopListPrice[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б�۸�
new PlayerText:PlayerShopListStock[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б���
new PlayerText:PlayerShopListAvatar[MAX_PLAYERS][MAX_SHOP_SHOW_LIST];//�б�ͷ��

new PlayerText:PlayerShopTitle[MAX_PLAYERS][4];//�����
new PlayerText:PlayerShopTitleText[MAX_PLAYERS][4];//�����
new PlayerText:PlayerShopBuyBackGround[MAX_PLAYERS];//���򱳾�
new PlayerText:PlayerShopCash[MAX_PLAYERS];//���Ǯ��
new PlayerText:PlayerShopBill[MAX_PLAYERS];//�˵�Ǯ��
new PlayerText:PlayerShopSlider[MAX_PLAYERS];//������

new bool:PlayerShopListShow[MAX_PLAYERS];//�б��Ƿ���ʾ*/


/************************************************************/
enum Level_Info
{
    _Exp,
    _Mod@Avatar,
    _GlobalInvSlots
}
new Level[][Level_Info] =
{
    {0,-2010,5},//ʿ ��
    {300,-2011,10},//�� ξ
    {600,-2012,20},//�� ξ
    {1200,-2013,30},//�� ξ
    {2400,-2014,40},//�� У
    {19200,-2015,50},//�� У
    {38400,-2016,60},//�� У
    {76800,-2017,70},//�� У
    {153600,-2018,80},//�� ��
    {307200,-2019,90},//�� ��
    {614400,-2020,100}//�� ��
};
/************************************************************///�������
new PlayerText:ErrorBoxClose[MAX_PLAYERS];//

new Text:ErrorBoxBackGround;//
new Text:ErrorBoxTagBackGround;//
new Text:ErrorBoxText_CuoWu;//
new Text:ErrorBoxText_NoLogin;//
new Text:ErrorBoxText_NoReg;//
new bool:PlayerErrorBoxShow[MAX_PLAYERS];//������ʾ
new ErrorBoxCloseRate[MAX_PLAYERS];


/************************************************************///�������
new Text:LoadingInterFaceBackGround;//
new Text:LoadingInterFaceText;//
/************************************************************///�û����
#define MAX_ACCOUNTPTD 16
new Text:AccountPanelTextDraw[MAX_ACCOUNTPTD];
new PlayerText:PlayerPanelAvatar[MAX_PLAYERS];//���ͷ��
new bool:PlayerPanelTextDrawShow[MAX_PLAYERS];//�����ʾ


new Text:AccountLevelTextDraw;//�ȼ�����������
new PlayerText:PlayerLevelAvatar[MAX_PLAYERS];//�ȼ�������ʾ
new PlayerText:PlayerLevelBar[MAX_PLAYERS];//�ȼ�������
new bool:PlayerLevelTextDrawShow[MAX_PLAYERS];//�ȼ���ʾ

new PlayerText:PlayerRightRotArrow[MAX_PLAYERS];//�����ͷ
new PlayerText:PlayerLeftRotArrow[MAX_PLAYERS];//�����ͷ
new PlayerClickRotMode[MAX_PLAYERS];//�����ͷ
/************************************************************///�����б�
#define MAX_ROOMBACKTEXTDRAWS 16
new Text:RoomBackTextDraw[MAX_ROOMBACKTEXTDRAWS];

#define MAX_ROOM_BOX_ITEMS MAX_GAMEROOMS+2
#define MAX_ROOM_SHOW_LIST 4
new PlayerRoomPrevieBox[MAX_PLAYERS][MAX_ROOM_BOX_ITEMS];
new PlayerRoomPrevieBoxKey[MAX_PLAYERS][MAX_ROOM_BOX_ITEMS][64];
new PlayerRoomPrevieBoxDrawID[MAX_PLAYERS][MAX_ROOM_BOX_ITEMS];
new PlayerRoomPrevieCount[MAX_PLAYERS];
new PlayerRoomPreviePage[MAX_PLAYERS];
new PlayerRoomPrevieRate[MAX_PLAYERS];
new PlayerRoomClickID[MAX_PLAYERS];


new PlayerText:PlayerRoomListBg[MAX_PLAYERS][MAX_ROOM_SHOW_LIST];//�б���
new PlayerText:PlayerRoomListNumber[MAX_PLAYERS][MAX_ROOM_SHOW_LIST];//�б����
new PlayerText:PlayerRoomListMap[MAX_PLAYERS][MAX_ROOM_SHOW_LIST];//�б��ͼ
new PlayerText:PlayerRoomListOwner[MAX_PLAYERS][MAX_ROOM_SHOW_LIST];//�б���
new PlayerText:PlayerRoomListOwnerID[MAX_PLAYERS][MAX_ROOM_SHOW_LIST];//�б���ID
new PlayerText:PlayerRoomListNP[MAX_PLAYERS][MAX_ROOM_SHOW_LIST];//�б�����
new PlayerText:PlayerRoomListLock[MAX_PLAYERS][MAX_ROOM_SHOW_LIST];//�б���
new PlayerText:PlayerRoomListSlider[MAX_PLAYERS];//�б������

new bool:PlayerRoomListShow[MAX_PLAYERS];//�б��Ƿ���ʾ
/************************************************************///��Ӫѡ��
#define MAX_GAMEROOM_CAMPSELECT 14
new Text:GameRoomCampSelectDraw[MAX_ROOMBACKTEXTDRAWS];
/********************��Ϸ��ѡ��*********************************/
#define MAX_GAMECONFIG_TEXTDRAWS 8
new Text:GameConfigTextDraw[MAX_ROOMBACKTEXTDRAWS];
new bool:PlayerGameConfigShow[MAX_PLAYERS]= {false, ...};//�б��Ƿ���ʾ
/*************************��������*******************************/
#define MAX_CREATEROOM_TEXTDRAWS 12
new Text:CreateRoomBackTextDraw[MAX_CREATEROOM_TEXTDRAWS];
new bool:PlayerCreateRoomShow[MAX_PLAYERS]= {false, ...};//�б��Ƿ���ʾ
new PlayerCreateRoomMap[MAX_PLAYERS]= {0, ...};//��ͼ
new PlayerCreateRoomMode[MAX_PLAYERS]= {0, ...};//ģʽ
new bool:PlayerCreateRoomLock[MAX_PLAYERS]= {false, ...};//��
new PlayerCreateRoomPassWord[MAX_PLAYERS][16];//����
new PlayerCreateRoomMaxPlayers[MAX_PLAYERS]= {0, ...};//�������
new PlayerText:PlayerCreateRoomMapIcon[MAX_PLAYERS]= {PlayerText:INVALID_TEXT_DRAW, ...};//��ͼԤ��
new PlayerText:PlayerCreateRoomMapText[MAX_PLAYERS]= {PlayerText:INVALID_TEXT_DRAW, ...};//��ͼ����
new PlayerText:PlayerCreateRoomMapLock[MAX_PLAYERS]= {PlayerText:INVALID_TEXT_DRAW, ...};//��
new PlayerText:PlayerCreateRoomMapMode[MAX_PLAYERS]= {PlayerText:INVALID_TEXT_DRAW, ...};//ģʽ
new PlayerText:PlayerCreateRoomMapPassWord[MAX_PLAYERS]= {PlayerText:INVALID_TEXT_DRAW, ...};//����
new PlayerText:PlayerCreateRoomMapMaxPlayers[MAX_PLAYERS]= {PlayerText:INVALID_TEXT_DRAW, ...};//�������
/************************************************************/
#define MAX_BUYGUN_TEXTDRAWS 107
new Text:GameRoomBuyGunTextDraw[MAX_BUYGUN_TEXTDRAWS];
new bool:GameRoomBuyGunShow[MAX_PLAYERS]= {false, ...};//�б��Ƿ���ʾ
new GameRoomWeaponType[MAX_PLAYERS]= {0, ...};
new GameRoomWeaponIndex[MAX_PLAYERS]= {0, ...};
/************************************************************/
enum//�Ի���ID
{
    _ERROR,
    _REGISTER,
    _LOGIN,
    
    _USE_GLOBALINV,
    _USE_GLOBALINV_DEL,
    _USE_GLOBALINV_DEL_AMOUNT,

    _ENTER_GAMEROOM,
    _ENTER_GAMEROOM_PASSWORD,
    
    _CREATEROOM_PASSWORD,
    _CREATEROOM_MAXPLAYERS,
}

new bool:DialogProtect_Opened[MAX_PLAYERS];
new DialogProtect_Key[MAX_PLAYERS];
new DialogProtect_Tick[MAX_PLAYERS];

N::Dialog@IsOpen(playerid)return DialogProtect_Opened[playerid];
N::Dialog@GetIndex(playerid)
{
	if(!DialogProtect_Opened[playerid])return NONE;
	return DialogProtect_Key[playerid];
}
N::Dialog@Rest(playerid)
{
    DialogProtect_Opened[playerid]=false;
	DialogProtect_Key[playerid]=NONE;
	DialogProtect_Tick[playerid]=0;
	return 1;
}
N::Dialog@Close(playerid)
{
    DialogProtect_Opened[playerid]=false;
	DialogProtect_Key[playerid]=NONE;
	DialogProtect_Tick[playerid]=0;
	ShowPlayerDialog(playerid,-1,DIALOG_STYLE_MSGBOX," ", " ", " ", "");
	return 1;
}
N::Dialog@Show(playerid,dialogid,style,caption[],info[],button1[],button2[])
{
	DialogProtect_Key[playerid]=dialogid;
	DialogProtect_Opened[playerid]=true;
	DialogProtect_Tick[playerid]=GetTickCount();
	ShowPlayerDialog(playerid,dialogid,style,caption,info,button1,button2);
	
    if(dialogid==_USE_GLOBALINV||dialogid==_USE_GLOBALINV_DEL||dialogid==_USE_GLOBALINV_DEL_AMOUNT)TogglePlayerGlobalInvSelectable(playerid,0);
	else TogglePlayerGlobalInvSelectable(playerid,1);
	return 1;
}

#include Tree\Object.pwn
#include DownLoadArt.pwn
#include Artconfig.pwn
#include Tree\HomePage\RoomList.pwn
#include Tree\HomePage\UserPanel.pwn
#include Tree\HomePage\Loading.pwn
#include Tree\HomePage\Error.pwn
#include Tree\HomePage\PlayerInv.pwn
#include Tree\HomePage\Shop.pwn
#include Tree\GameRoom\GameMain.pwn
#include Tree\GameRoom\CampSelection.pwn
#include Tree\GameRoom\GameConfig.pwn
#include Tree\GameRoom\GameTag.pwn
#include Tree\GameRoom\BuyGun.pwn
#include Tree\GameRoom\Weapon.pwn
#include Tree\Account.pwn

main()
{
    formatex128("hostname "SERVER_HOSTNAME"");
	SendRconCommand(string128);
	formatex128("gamemodetext "SERVER_GAMETEXT"");
	SendRconCommand(string128);
	formatex128("mapname "SERVER_MAPNAME"");
	SendRconCommand(string128);
	formatex128("weburl "SERVER_WEBURL"");
	SendRconCommand(string128);
	formatex128("language "SERVER_LANGUAGE"");
	SendRconCommand(string128);
}
stock HighestTopList(const playerid, const Value, Player_ID[], Top_Score[], Loop) 	//	 Created by Phento
{
	new
		t = 0,
		p = Loop-1;
	while(t <= p) {
		if(Value >= Top_Score[t]) {
			if(Top_Score[t+1] <= 0) p = t+1;
			while(p > t) { Top_Score[p] = Top_Score[p - 1]; Player_ID[p] = Player_ID[p - 1]; p--; }
			Top_Score[t] = Value; Player_ID[t] = playerid;
			break;
		} t++; }
	return 1;
}

public OnGameModeInit()
{
    EnableVehicleFriendlyFire();
    DisableInteriorEnterExits();
 	EnableStuntBonusForAll(0);
    ManualVehicleEngineAndLights();
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(0);
    UsePlayerPedAnims();
    
    SetDamageFeed(false);
    SetDamageSounds(0, 0);
    SetCbugAllowed(false);
    SetCustomVendingMachines(false);
	SetVehiclePassengerDamage(true);
	SetVehicleUnoccupiedDamage(true);
    SetDisableSyncBugs(true);
    
    
	ArtConfigInit();
	
    Iter_Init(_@PlayerTextDraws);
    Iter_Init(PlayerGlobalInv);
    Iter_Init(PlayerDownloadFiles);
    Iter_Init(GameRoomMapObjects);
    LoadingInterFaceInt();
    ErrorBoxTextDrawInt();
    DownLoadArtTextDrawInt();
    RoomBackGroundInt();
    AccountPanelBackGroundInt();
    PlayerGlobalInvBackGroundInt();
    ShopBackGroundInt();
    GameRoomCampSelectDrawInt();
    GameConfigDrawInt();
    CreateRoomBackGroundInt();
    GameRoomTagDrawInt();
    GameRoomBuyGunDrawInt();

   	forex(i,MAX_PLAYERS)
	{
	    RestPlayerRoomListDraws(i,false);
	    RestPlayerAccountPanelDraws(i,false);
	    RestPlayerLevelDraws(i,false);
	    RestPlayerGlobalInvDraws(i,false);
	    RestPlayerShopDraws(i,false,true);
	    RestPlayerPlayerDownLoadDraws(i,false);
	    //RestPlayerHpBar(i,false);
	    RestPlayerErrorBoxDraws(i,false);
	    RestPlayerCreateRoomDraws(i,false);

	    PlayerGlobalInvRest(i);
        RestPlayerGameRoomData(i,false);
	}
	
    forex(i,MAX_GAMEROOMS)RestGameRoomTag(i,false);
    
    mysql_log(LOG_ERROR|LOG_WARNING);
    User@Handle=mysql_connect(MYSQL_HOST,MYSQL_USER,MYSQL_DB,MYSQL_PASS);
    mysql_set_charset("gbk",User@Handle);
    if(mysql_errno(User@Handle)!=0)
	{
		print("�������ݿ�ʧ��<1>");
		SendRconCommand("exit");
	}

    ScenesObjectInt();
    
    SetTimer("Timer@SecondUpdate",1000,true);

	forex(i,MAX_GAMEROOMS/10)CreateGameRoom("SYSTEM_OWNER",random(8),0,10,false,"");
	
	printf("DFF�ļ�:%i  TXD�ļ�:%i ",GlobalFilesDFF,GlobalFilesTXD);
	
	return 1;
}

N::Timer@SecondUpdate()
{
	foreach(new i:Player)
	{
	    if(PlayerErrorBoxShow[i]==true)
	    {
	        if(ErrorBoxClose[i]!=PlayerText:INVALID_TEXT_DRAW)
	        {
		        if(ErrorBoxCloseRate[i]==0)
		        {
		            PlayerTextDrawColor(i, ErrorBoxClose[i], -1);
		            ErrorBoxCloseRate[i]=1;
		        }
		        else
		        {
		            PlayerTextDrawColor(i, ErrorBoxClose[i], 255);
		            ErrorBoxCloseRate[i]=0;
		        }
		        PlayerTextDrawShow(i, ErrorBoxClose[i]);
	        }
	    }
	}
	foreach(new i:GameRoom)
	{
	    if(Iter_Contains(GameRoom,i))
	    {
	        if(GetPlayerAmountsInGameRoom(i)>0)
	        {
			    GameRoom[i][_CurrentRoundTime]++;
			    if(GameRoom[i][_CurrentRoundTime]>=GameRoom[i][_MaxRoundTime])
			    {
			        GameRoom[i][_CurrentRoundTime]=0;
			        GameRoom[i][_CurrentRoundMap]++;
			        if(GameRoom[i][_MaxRoundMap]==NONE)
			        {
			            OnGameRoundMapChange(i);
			        }
			        else
			        {
			            OnGameRoundTimeChange(i);
			        }
			    }
		        if(GameRoomTeamTag[i][_LastTime]!=Text:INVALID_TEXT_DRAW)
				{
				    formatex32(ReturnConvertSec(GameRoom[i][_MaxRoundTime]-GameRoom[i][_CurrentRoundTime]));
				    TextDrawSetString(GameRoomTeamTag[i][_LastTime],string32);
					UpdateGameRoomTagForGamePlayers(i,GameRoomTeamTag[i][_LastTime]);
				}
			}
		}
	}
	return 1;
}
public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if(clickedid==Text:INVALID_TEXT_DRAW)
    {
	    if(PlayerGameRoom[playerid][_State]!=STATE_PLAYING)
		{
			SelectTextDraw(playerid, 0xFF8500FF);
		}
		else
		{
		    if(PlayerGameConfigShow[playerid]==true)HidePlayerGameConfig(playerid);
		    if(GameRoomBuyGunShow[playerid]==true)HidePlayerBuyGunMain(playerid);
		}
        return 1;
    }
    
	if(PlayerErrorBoxShow[playerid]==true)//����ҳ��
	{
       	return 1;
	}
    if(clickedid==RoomBackTextDraw[10])//�������䰴ť
    {
		if(Account[playerid][_Register]==false)return ShowPlayerErrorBox(playerid,0);
		if(Account[playerid][_Login]==false)return ShowPlayerErrorBox(playerid,1);
		CreatePlayerCreateRoom(playerid);
    }
    if(clickedid==RoomBackTextDraw[11])//�Զ�ƥ�䰴ť
    {
		if(Account[playerid][_Register]==false)return ShowPlayerErrorBox(playerid,0);
		if(Account[playerid][_Login]==false)return ShowPlayerErrorBox(playerid,1);
		
    }
    if(clickedid==RoomBackTextDraw[12])//����ID��ť
    {
		if(Account[playerid][_Register]==false)return ShowPlayerErrorBox(playerid,0);
		if(Account[playerid][_Login]==false)return ShowPlayerErrorBox(playerid,1);
		
    }
    /*******************************************************************************/
    if(clickedid==CreateRoomBackTextDraw[5])//������ͼ--
    {
        if(PlayerCreateRoomShow[playerid]==true)
        {
            PlayerCreateRoomMap[playerid]--;
            if(PlayerCreateRoomMap[playerid]<0)
            {
                PlayerCreateRoomMap[playerid]=sizeof(Map)-1;
            }
            if(PlayerCreateRoomMapIcon[playerid]!=PlayerText:INVALID_TEXT_DRAW)
            {
            	PlayerTextDrawSetPreviewModel(playerid, PlayerCreateRoomMapIcon[playerid], Map[PlayerCreateRoomMap[playerid]][_Mod@Avatar]);
                PlayerTextDrawShow(playerid,PlayerCreateRoomMapIcon[playerid]);
			}
            if(PlayerCreateRoomMapText[playerid]!=PlayerText:INVALID_TEXT_DRAW)
            {
                PlayerTextDrawSetPreviewModel(playerid, PlayerCreateRoomMapText[playerid], Map[PlayerCreateRoomMap[playerid]][_Mod@Name]);
                PlayerTextDrawShow(playerid,PlayerCreateRoomMapText[playerid]);
            }
        }
    }
    if(clickedid==CreateRoomBackTextDraw[6])//������ͼ++
    {
        if(PlayerCreateRoomShow[playerid]==true)
        {
            PlayerCreateRoomMap[playerid]++;
            if(PlayerCreateRoomMap[playerid]>=sizeof(Map))
            {
                PlayerCreateRoomMap[playerid]=0;
            }
            if(PlayerCreateRoomMapIcon[playerid]!=PlayerText:INVALID_TEXT_DRAW)
            {
            	PlayerTextDrawSetPreviewModel(playerid, PlayerCreateRoomMapIcon[playerid], Map[PlayerCreateRoomMap[playerid]][_Mod@Avatar]);
                PlayerTextDrawShow(playerid,PlayerCreateRoomMapIcon[playerid]);
			}
            if(PlayerCreateRoomMapText[playerid]!=PlayerText:INVALID_TEXT_DRAW)
            {
                PlayerTextDrawSetPreviewModel(playerid, PlayerCreateRoomMapText[playerid], Map[PlayerCreateRoomMap[playerid]][_Mod@Name]);
                PlayerTextDrawShow(playerid,PlayerCreateRoomMapText[playerid]);
            }
        }
    }
    if(clickedid==CreateRoomBackTextDraw[9])//ȷ������
    {
        CreateGameRoom(Account[playerid][_Key],PlayerCreateRoomMap[playerid],PlayerCreateRoomMode[playerid],GameMaxPlayer[PlayerCreateRoomMaxPlayers[playerid]][_Amount],PlayerCreateRoomLock[playerid],PlayerCreateRoomPassWord[playerid]);
        HidePlayerCreateRoom(playerid);
        RestPlayerCreateRoomDraws(playerid,true);
    }
    if(clickedid==CreateRoomBackTextDraw[10])//ȡ������
    {
        HidePlayerCreateRoom(playerid);
        RestPlayerCreateRoomDraws(playerid,true);

    }
    /*******************************************************************************/
	if(clickedid==RoomBackTextDraw[7])//�����б���һҳ
	{
	    new pages=PlayerRoomPreviePage[playerid];
    	PlayerRoomPreviePage[playerid]--;
		if(PlayerRoomPreviePage[playerid]<1)PlayerRoomPreviePage[playerid]=1;
		if(pages!=PlayerRoomPreviePage[playerid])
		{
			return RefreshPlayerRoomPage(playerid,PlayerRoomPreviePage[playerid]);
        }
        return 1;
	}
	if(clickedid==RoomBackTextDraw[8])//�����б���һҳ
	{
   		new pages=PlayerRoomPreviePage[playerid];
     	PlayerRoomPreviePage[playerid]++;
      	if(PlayerRoomPreviePage[playerid]>floatround((PlayerRoomPrevieCount[playerid]-1)/float(MAX_ROOM_SHOW_LIST),floatround_ceil))PlayerRoomPreviePage[playerid]--;
		if(pages!=PlayerRoomPreviePage[playerid])
		{
			return RefreshPlayerRoomPage(playerid,PlayerRoomPreviePage[playerid]);
  		}
  		return 1;
	}
	
	if(clickedid==PlayerGlobalInvBackTextDraw[4])//���������б���һҳ
	{
	    new pages=PlayerGlobalInvPreviePage[playerid];
    	PlayerGlobalInvPreviePage[playerid]--;
		if(PlayerGlobalInvPreviePage[playerid]<1)PlayerGlobalInvPreviePage[playerid]=1;
		if(pages!=PlayerGlobalInvPreviePage[playerid])
		{
			return RefreshPlayerGlobalInvPage(playerid,PlayerGlobalInvPreviePage[playerid]);
        }
        return 1;
	}
	if(clickedid==PlayerGlobalInvBackTextDraw[5])//���������б���һҳ
	{
   		new pages=PlayerGlobalInvPreviePage[playerid];
     	PlayerGlobalInvPreviePage[playerid]++;
      	if(PlayerGlobalInvPreviePage[playerid]>floatround((PlayerGlobalInvPrevieCount[playerid]-1)/float(MAX_PLAYERGLOBALINV_SHOW_LIST),floatround_ceil))PlayerGlobalInvPreviePage[playerid]--;
		if(pages!=PlayerGlobalInvPreviePage[playerid])
		{
			return RefreshPlayerGlobalInvPage(playerid,PlayerGlobalInvPreviePage[playerid]);
  		}
  		return 1;
	}
	if(clickedid==PlayerGlobalInvBackTextDraw[7])//�����������ش���
	{
        HidePlayerGlobalInvBackGround(playerid);
        RestPlayerGlobalInvDraws(playerid,true);
		ShowPlayerRoomBackGround(playerid);
		CreatePlayerRoomPage(playerid,1);
	    ShowPlayerAccountPanel(playerid,true);
	    ShowPlayerLevelDraws(playerid);

	    SetPlayerPos(playerid,-561.8014,465.1385,114.7091);
	    SetPlayerFacingAngle(playerid,Account[playerid][_FaceAngle]);
		SetPlayerCameraPos(playerid,-559.05,463.9912,114.7091);
		SetPlayerCameraLookAt(playerid,-561.8014,463.9912,114.7091,CAMERA_MOVE);
  		return 1;
	}
	
	if(clickedid==ShopBackTextDraw[2])//�̵��б���һҳ
	{
	    new pages=PlayerShopPreviePage[playerid];
    	PlayerShopPreviePage[playerid]--;
		if(PlayerShopPreviePage[playerid]<1)PlayerShopPreviePage[playerid]=1;
		if(pages!=PlayerShopPreviePage[playerid])
		{
			return RefreshPlayerShopPage(playerid,PlayerShopType[playerid],PlayerShopPreviePage[playerid]);
        }
        return 1;
	}
	if(clickedid==ShopBackTextDraw[3])//�̵��б���һҳ
	{
   		new pages=PlayerShopPreviePage[playerid];
     	PlayerShopPreviePage[playerid]++;
      	if(PlayerShopPreviePage[playerid]>floatround((PlayerShopPrevieCount[playerid]-1)/float(MAX_SHOP_SHOW_LIST),floatround_ceil))PlayerShopPreviePage[playerid]--;
		if(pages!=PlayerShopPreviePage[playerid])
		{
			return RefreshPlayerShopPage(playerid,PlayerShopType[playerid],PlayerShopPreviePage[playerid]);
  		}
  		return 1;
	}
	if(clickedid==ShopBackTextDraw[8])//�̵깺��
	{
	    new PayMoney=GetPlayerBillMoney(playerid);
	    if(PayMoney>0)
	    {
			if(Account[playerid][_Cash]>=PayMoney)
			{
				forex(i,MAX_ITEMS)
				{
	   				if(PlayerShopItemAmounts[playerid][i]>0&&PlayerShopItemAmounts[playerid][i]<=Item[i][_Stock])
				    {
			            AddItemToPlayerGlobalInv(playerid,Item[i][_Key],PlayerShopItemAmounts[playerid][i]);
			            Item[i][_Stock]-=PlayerShopItemAmounts[playerid][i];
	                    OnShopStockChanged(i,Item[i][_Stock],Item[i][_Key]);
	                    PlayerShopItemAmounts[playerid][i]=0;
				    }
				    PlayerShopItemAmounts[playerid][i]=0;
				}
				if(PlayerShopListShow[playerid]==true)
				{
				    forex(i,MAX_SHOP_SHOW_LIST)
				    {
	       				if(PlayerShopListBuyAmount[playerid][i]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawSetString(playerid,PlayerShopListBuyAmount[playerid][i],"0");
				    }
				    formatex32("%i",GetPlayerBillMoney(playerid));
				    if(PlayerShopBill[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawSetString(playerid,PlayerShopBill[playerid],string32);
				}
				Account[playerid][_Cash]-=PayMoney;
				Hooks("Update@AccountCash","ii",playerid,Account[playerid][_Cash]);
				formatex32("%i",Account[playerid][_Cash]);
				if(PlayerShopCash[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawSetString(playerid,PlayerShopCash[playerid],string32);
			}
			else Dialog@Show(playerid,_ERROR,DIALOG_STYLE_MSGBOX,"����[#2]","��û���㹻��C���������ﳵ�����Ʒ","�˽�","");
	    }
	    else Dialog@Show(playerid,_ERROR,DIALOG_STYLE_MSGBOX,"����[#2]","�㻹û�ж�����Ʒ","�˽�","");
	}
	if(clickedid==ShopBackTextDraw[12])//��չ��ﳵ
	{
	    if(GetPlayerBillMoney(playerid)>0)
	    {
			forex(i,MAX_ITEMS)
			{
			    if(PlayerShopItemAmounts[playerid][i]>0)PlayerShopItemAmounts[playerid][i]=0;
			}
			if(PlayerShopListShow[playerid]==true)
			{
			    forex(i,MAX_SHOP_SHOW_LIST)
			    {
       				if(PlayerShopListBuyAmount[playerid][i]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawSetString(playerid,PlayerShopListBuyAmount[playerid][i],"0");
			    }
			    formatex32("%i",GetPlayerBillMoney(playerid));
			    if(PlayerShopBill[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawSetString(playerid,PlayerShopBill[playerid],string32);
			}
		}
		else Dialog@Show(playerid,_ERROR,DIALOG_STYLE_MSGBOX,"����[#2]","��Ĺ��ﳵ�ﻹû�ж���","�˽�","");
		return 1;
	}
	if(clickedid==ShopBackTextDraw[10])//�̵귵�ش���
	{
        HidePlayerShopBackGround(playerid);
        RestPlayerShopDraws(playerid,true,true);
		ShowPlayerRoomBackGround(playerid);
		CreatePlayerRoomPage(playerid,1);
	    ShowPlayerAccountPanel(playerid,true);
	    ShowPlayerLevelDraws(playerid);

	    SetPlayerPos(playerid,-561.8014,465.1385,114.7091);
	    SetPlayerFacingAngle(playerid,Account[playerid][_FaceAngle]);
		SetPlayerCameraPos(playerid,-559.05,463.9912,114.7091);
		SetPlayerCameraLookAt(playerid,-561.8014,463.9912,114.7091,CAMERA_MOVE);
  		return 1;
	}
	

	
	if(clickedid==AccountPanelTextDraw[1])//ע��
	{
	    if(Account[playerid][_Register]==false)
	    {
	        Dialog@Show(playerid,_REGISTER,DIALOG_STYLE_INPUT,"ע���˺�","������������ע��","ȷ��","�ر�");
	    }
	}
	if(clickedid==AccountPanelTextDraw[2])//��¼
	{
	    if(Account[playerid][_Register]==true)
	    {
	        Dialog@Show(playerid,_LOGIN,DIALOG_STYLE_INPUT,"��¼�˺�","��������������¼","ȷ��","�ر�");
	    }
	}
	if(clickedid==AccountPanelTextDraw[6])//������ť
	{
	    ClearChat(playerid);
	}
	if(clickedid==AccountPanelTextDraw[4])//Ƥ���̵�
	{
        HidePlayerRoomBackGround(playerid);
        RestPlayerRoomListDraws(playerid,true);
        HidePlayerAccountPanel(playerid);
        RestPlayerAccountPanelDraws(playerid,true);
        HidePlayerLevelDraws(playerid);
        RestPlayerLevelDraws(playerid,true);
        SetPlayerPos(playerid,-561.8014,465.1385,114.7091);
        SetPlayerFacingAngle(playerid,Account[playerid][_FaceAngle]);
       	SetPlayerCameraPos(playerid,-559.05,466.9912,114.7091);
		SetPlayerCameraLookAt(playerid,-561.8014,466.5,114.7091,CAMERA_MOVE);

        ShowPlayerShopBackGround(playerid);
        CreateShopPage(playerid,SHOP_TYPE_ALL,true,1);
//		ShowSkinShopBackGround(playerid);
//        CreateSkinShopPage(playerid,1);
	}
	if(clickedid==AccountPanelTextDraw[3])//��������
	{
        HidePlayerRoomBackGround(playerid);
        RestPlayerRoomListDraws(playerid,true);
        HidePlayerAccountPanel(playerid);
        RestPlayerAccountPanelDraws(playerid,true);
        HidePlayerLevelDraws(playerid);
        RestPlayerLevelDraws(playerid,true);
        SetPlayerPos(playerid,-561.8014,465.1385,114.7091);
        SetPlayerFacingAngle(playerid,Account[playerid][_FaceAngle]);
       	SetPlayerCameraPos(playerid,-559.05,466.9912,114.7091);
		SetPlayerCameraLookAt(playerid,-561.8014,466.5,114.7091,CAMERA_MOVE);
		ShowPlayerGlobalInvBackGround(playerid);
        CreatePlayerGlobalInvPage(playerid,1);
	}
	/*********************************************************************/
	if(clickedid==GameRoomCampSelectDraw[2])//ѡ��ֲ�����
	{
	    HidePlayerGameRoomCampSelect(playerid);
	    new GameID=PlayerGameRoom[playerid][_GameID];
     	PlayerGameRoom[playerid][_Team]=TEAM_TER;
	    SetPlayerPos(playerid,Map[GameRoom[GameID][_MapID]][_Ter_SpawnX],Map[GameRoom[GameID][_MapID]][_Ter_SpawnY],Map[GameRoom[GameID][_MapID]][_Ter_SpawnZ]);
        SetCameraBehindPlayer(playerid);
        TogglePlayerControllable(playerid, 0);
        GameFreezePlayer(playerid,GameRoom[GameID][_MaxFreezeTime]);
        PlayerGameRoom[playerid][_State]=STATE_PLAYING;
        CancelSelectTextDraw(playerid);
        SetHealthBarVisibleEx(playerid, true);
        SetPlayerHealth(playerid,100.0);
        SetPlayerArmour(playerid,0.0);
        AddPlayerInGameRoomTag(playerid,GameID,TEAM_TER);
	}
	if(clickedid==GameRoomCampSelectDraw[3])//ѡ�񷴿־�Ӣ
	{
	    HidePlayerGameRoomCampSelect(playerid);
	    new GameID=PlayerGameRoom[playerid][_GameID];
     	PlayerGameRoom[playerid][_Team]=TEAM_COP;
	    SetPlayerPos(playerid,Map[GameRoom[GameID][_MapID]][_Cop_SpawnX],Map[GameRoom[GameID][_MapID]][_Cop_SpawnY],Map[GameRoom[GameID][_MapID]][_Cop_SpawnZ]);
        SetCameraBehindPlayer(playerid);
        TogglePlayerControllable(playerid, 0);
        GameFreezePlayer(playerid,GameRoom[GameID][_MaxFreezeTime]);
        PlayerGameRoom[playerid][_State]=STATE_PLAYING;
        CancelSelectTextDraw(playerid);
        SetHealthBarVisibleEx(playerid, true);
        SetPlayerHealth(playerid,100.0);
        SetPlayerArmour(playerid,0.0);
        AddPlayerInGameRoomTag(playerid,GameID,TEAM_COP);
	}
	if(clickedid==GameRoomCampSelectDraw[4])//ѡ���Զ�����
	{
	}
	if(clickedid==GameRoomCampSelectDraw[5])//ѡ��۲���
	{
	}
	if(clickedid==GameRoomCampSelectDraw[6])//ѡ���뿪
	{
	    QuitPlayerFromGameRoom(playerid);
	}
	/*********************************************************************/
	if(clickedid==GameConfigTextDraw[0])//���ط���
	{
	    HidePlayerGameConfig(playerid);
		CancelSelectTextDraw(playerid);
	}
	if(clickedid==GameConfigTextDraw[1])//��������
	{
	}
	if(clickedid==GameConfigTextDraw[2])//������Ӫ
	{
	}
	if(clickedid==GameConfigTextDraw[3])//�뿪����
	{
	    QuitPlayerFromGameRoom(playerid);
	}
	/*******************************************************************/
	if(clickedid==GameRoomBuyGunTextDraw[41])//buyit
	{
	    BuyWeaponGiveWeapon(playerid,GameRoomWeaponType[playerid],GameRoomWeaponIndex[playerid]);
	    /*switch(GameRoomWeaponType[playerid])
	    {
	        case 1..4:BuyWeaponGiveWeapon(playerid,GameRoomWeaponType[playerid],GameRoomWeaponIndex[playerid]);
			case 6:
			{
				if(GameRoomWeaponIndex[playerid]>=1&&GameRoomWeaponIndex[playerid]<=3)
				else
				{
				}
			}
	    }*/
	}
	////////////////////////////////////////////////////////////////////
	
	if(clickedid==GameRoomBuyGunTextDraw[4])//������ǹ����
	{
	    ShowPlayerBuyPistol(playerid);
	}
	if(clickedid==GameRoomBuyGunTextDraw[27])//9mm
	{
	    loop(i,33,42)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[34]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[38]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=1;
	}
	if(clickedid==GameRoomBuyGunTextDraw[28])//s9mm
	{
	    loop(i,33,42)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[35]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[39]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=2;
	}

	if(clickedid==GameRoomBuyGunTextDraw[29])//deagle
	{
	    loop(i,33,42)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[36]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[40]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=3;
	}
	/////////////////////////////////////////////////////////////////////
	if(clickedid==GameRoomBuyGunTextDraw[5])//����ɢ������
	{
	    ShowPlayerBuyShotgun(playerid);
	}
	if(clickedid==GameRoomBuyGunTextDraw[43])//Shotgun
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,50,56)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[50]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[53]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=1;
	}
	if(clickedid==GameRoomBuyGunTextDraw[44])//Sawnoff
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,50,56)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[51]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[54]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=2;
	}

	if(clickedid==GameRoomBuyGunTextDraw[45])//Combat
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,50,56)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[52]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[55]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=3;
	}
	/////////////////////////////////////////////////////////////////////
	if(clickedid==GameRoomBuyGunTextDraw[6])//����UZI����
	{
	    ShowPlayerBuyUzi(playerid);
	}
	if(clickedid==GameRoomBuyGunTextDraw[56])//Shotgun
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,63,69)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[63]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[66]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=1;
	}
	if(clickedid==GameRoomBuyGunTextDraw[57])//Sawnoff
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,63,69)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[64]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[67]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=2;
	}

	if(clickedid==GameRoomBuyGunTextDraw[58])//Combat
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,63,69)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[65]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[68]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=3;
	}
	/////////////////////////////////////////////////////////////////////
	if(clickedid==GameRoomBuyGunTextDraw[7])//����ǹ����
	{
	    ShowPlayerBuyRifle(playerid);
	}
	if(clickedid==GameRoomBuyGunTextDraw[69])//AK-47
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,78,86)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[78]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[82]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=1;
	}
	if(clickedid==GameRoomBuyGunTextDraw[70])//M4
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,78,86)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[79]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[83]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=2;
	}
	if(clickedid==GameRoomBuyGunTextDraw[71])//Country Rifle
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,78,86)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[80]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[84]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=3;
	}
	if(clickedid==GameRoomBuyGunTextDraw[72])//Sniper Rifle
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,78,86)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[81]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[85]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=4;
	}
	/////////////////////////////////////////////////////////////////////
	if(clickedid==GameRoomBuyGunTextDraw[11])//����װ������
	{
	    ShowPlayerBuyEquipment(playerid);
	}
	if(clickedid==GameRoomBuyGunTextDraw[86])//AK-47
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,97,107)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[97]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[102]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=1;
	}
	if(clickedid==GameRoomBuyGunTextDraw[87])//M4
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,97,107)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[98]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[103]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=2;
	}
	if(clickedid==GameRoomBuyGunTextDraw[88])//Country Rifle
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,97,107)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[99]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[104]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=3;
	}
	if(clickedid==GameRoomBuyGunTextDraw[89])//Sniper Rifle
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,97,107)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[100]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[105]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=4;
	}
	if(clickedid==GameRoomBuyGunTextDraw[90])//Sniper Rifle
	{
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    loop(i,97,107)TextDrawHideForPlayer(playerid,GameRoomBuyGunTextDraw[i]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[33]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[101]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[37]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[106]);
	    TextDrawShowForPlayer(playerid,GameRoomBuyGunTextDraw[41]);
	    GameRoomWeaponIndex[playerid]=5;
	}
	/////////////////////////////////////////////////////////////////////
	if(clickedid==GameRoomBuyGunTextDraw[42])
	{
	    ShowPlayerBuyGunMain(playerid);
	}
	if(clickedid==GameRoomBuyGunTextDraw[12])
	{
	    HidePlayerBuyGunMain(playerid);
	    CancelSelectTextDraw(playerid);
	}
	/*******************************************************************/
	return 1;
}
public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if(playertextid != PlayerText:INVALID_TEXT_DRAW)
    {
	    if(PlayerErrorBoxShow[playerid]==true)
	    {
			if(playertextid==ErrorBoxClose[playerid])
			{
			    return HidePlayerErrorBox(playerid);
			}
			return 1;
		}
		/***********************************************************************************************/
        if(playertextid == PlayerRightRotArrow[playerid])//��������ת
        {
            if(PlayerClickRotMode[playerid]==2)
            {
                PlayerClickRotMode[playerid]=0;
                Update@AccountFaceAngle(playerid,Account[playerid][_FaceAngle]);
                if(PlayerRightRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerRightRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerRightRotArrow[playerid]);
                if(PlayerLeftRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerLeftRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerLeftRotArrow[playerid]);
            }
            else
			{
				PlayerClickRotMode[playerid]=2;
                if(PlayerRightRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerRightRotArrow[playerid], -59);PlayerTextDrawShow(playerid, PlayerRightRotArrow[playerid]);
                if(PlayerLeftRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerLeftRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerLeftRotArrow[playerid]);
			}
            return 1;

        }
        if(playertextid == PlayerLeftRotArrow[playerid])//��������ת
        {
            if(PlayerClickRotMode[playerid]==1)
            {
                PlayerClickRotMode[playerid]=0;
                Update@AccountFaceAngle(playerid,Account[playerid][_FaceAngle]);
                if(PlayerRightRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerRightRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerRightRotArrow[playerid]);
                if(PlayerLeftRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerLeftRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerLeftRotArrow[playerid]);
            }
            else
			{
				PlayerClickRotMode[playerid]=1;
                if(PlayerRightRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerRightRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerRightRotArrow[playerid]);
                if(PlayerLeftRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerLeftRotArrow[playerid], -59);PlayerTextDrawShow(playerid, PlayerLeftRotArrow[playerid]);
			}
            return 1;
        }
        /***********************************************************************************************/
		forex(i,MAX_ROOM_SHOW_LIST)//���ҵ������ID-��ͼ
		{
		    if(playertextid==PlayerRoomListMap[playerid][i])
			{
   				if(Account[playerid][_Register]==false)return ShowPlayerErrorBox(playerid,0);
    			if(Account[playerid][_Login]==false)return ShowPlayerErrorBox(playerid,1);
				new pages=PlayerRoomPreviePage[playerid]-1;
                if(pages<1)pages=0;
                new index=pages*MAX_ROOM_SHOW_LIST+i+1;
                printf("PlayerRoomListMap %i",index);
                return 1;
			}
		}
		forex(i,MAX_ROOM_SHOW_LIST)//���ҵ������-����
		{
		    if(playertextid==PlayerRoomListOwner[playerid][i])
			{
   				if(Account[playerid][_Register]==false)return ShowPlayerErrorBox(playerid,0);
    			if(Account[playerid][_Login]==false)return ShowPlayerErrorBox(playerid,1);
                new pages=PlayerRoomPreviePage[playerid]-1;
                if(pages<1)pages=0;
                new index=pages*MAX_ROOM_SHOW_LIST+i+1;
                printf("PlayerRoomListOwner %i",index);
                return 1;
			}
		}
		forex(i,MAX_ROOM_SHOW_LIST)//���ҵ������-ID
		{
		    if(playertextid==PlayerRoomListBg[playerid][i])
			{
   				if(Account[playerid][_Register]==false)return ShowPlayerErrorBox(playerid,0);
    			if(Account[playerid][_Login]==false)return ShowPlayerErrorBox(playerid,1);
                new pages=PlayerRoomPreviePage[playerid]-1;
                if(pages<1)pages=0;
                new index=pages*MAX_ROOM_SHOW_LIST+i+1;
                OnPlayerClickGameRoomListBg(playerid,index);
                //Hooks("OnPlayerClickGameRoomListBg","ii",playerid,index);
                printf("PlayerRoomListBg %i",index);
                
                return 1;
			}
		}
		/*******************************************************************************/
		if(PlayerCreateRoomShow[playerid]==true)
		{
			if(playertextid==PlayerCreateRoomMapMaxPlayers[playerid])
			{
			    new str[8],body[128];
			    forex(i,sizeof(GameMaxPlayer))
			    {
			        format(str,sizeof(str),"%i��\n",GameMaxPlayer[i][_Amount]);
			        strcat(body,str);
			    }
			    Dialog@Show(playerid,_CREATEROOM_MAXPLAYERS,DIALOG_STYLE_LIST,"�����������",body,"ȷ��","����");
			}
			if(playertextid==PlayerCreateRoomMapLock[playerid])
			{
			    if(PlayerCreateRoomLock[playerid]==true)
			    {
		            if(PlayerCreateRoomMapLock[playerid]!=PlayerText:INVALID_TEXT_DRAW)
		            {
		                PlayerTextDrawSetPreviewModel(playerid, PlayerCreateRoomMapLock[playerid], -2025);
		                PlayerTextDrawShow(playerid,PlayerCreateRoomMapLock[playerid]);
		            }
		            if(PlayerCreateRoomMapPassWord[playerid]!=PlayerText:INVALID_TEXT_DRAW)
		            {
		            	PlayerTextDrawSetString(playerid,PlayerCreateRoomMapPassWord[playerid],"_");
		                PlayerTextDrawShow(playerid,PlayerCreateRoomMapPassWord[playerid]);
		            }
		            PlayerCreateRoomLock[playerid]=false;
			    }
			    else
			    {
		            if(PlayerCreateRoomMapLock[playerid]!=PlayerText:INVALID_TEXT_DRAW)
		            {
		                PlayerTextDrawSetPreviewModel(playerid, PlayerCreateRoomMapLock[playerid], -2024);
		                PlayerTextDrawShow(playerid,PlayerCreateRoomMapLock[playerid]);
		            }
		            if(PlayerCreateRoomMapPassWord[playerid]!=PlayerText:INVALID_TEXT_DRAW)
		            {
		                format(PlayerCreateRoomPassWord[playerid],16," ");
		            	PlayerTextDrawSetString(playerid,PlayerCreateRoomMapPassWord[playerid],"~r~UNSET");
		                PlayerTextDrawShow(playerid,PlayerCreateRoomMapPassWord[playerid]);
		            }
		            PlayerCreateRoomLock[playerid]=true;
		            Dialog@Show(playerid,_CREATEROOM_PASSWORD,DIALOG_STYLE_INPUT,"��������","������Ҫ���õķ�������\nֻ������","ȷ��","����");
			    }
			}
		}
		/***********************************************************************************************/
		forex(i,4)//�̵�����б�
		{
			if(playertextid==PlayerShopTitle[playerid][i])
			{
			    if(PlayerShopType[playerid]!=i)
			    {
				    PlayerShopPreviePage[playerid]=1;
					RefreshPlayerShopPage(playerid,i,PlayerShopPreviePage[playerid]);
				}
			}
		}
		forex(i,MAX_SHOP_SHOW_LIST)//+����
		{
		    if(playertextid==PlayerShopListJiaBack[playerid][i])
			{
			    if(PlayerShopListShow[playerid]==true)
			    {
                	new pages=PlayerShopPreviePage[playerid]-1;
                	if(pages<1)pages=0;
               		new index=pages*MAX_SHOP_SHOW_LIST+i+1;
                	new Amount=PlayerShopItemAmounts[playerid][PlayerShopPrevieBox[playerid][index]];
                    Amount++;
			        if(Amount<=20&&Amount<=Item[PlayerShopPrevieBox[playerid][index]][_Stock])
			        {
			            if(IsPlayerShopingInvFull(playerid,PlayerShopPrevieBox[playerid][index],Amount)==0)
			            {
				            PlayerShopItemAmounts[playerid][PlayerShopPrevieBox[playerid][index]]=Amount;
					        if(PlayerShopListBuyAmount[playerid][i]!=PlayerText:INVALID_TEXT_DRAW)
					        {
					            formatex32("%i",PlayerShopItemAmounts[playerid][PlayerShopPrevieBox[playerid][index]]);
								PlayerTextDrawSetString(playerid,PlayerShopListBuyAmount[playerid][i],string32);
					        }
					        if(PlayerShopBill[playerid]!=PlayerText:INVALID_TEXT_DRAW)
					        {
					            formatex32("%i",GetPlayerBillMoney(playerid));
								PlayerTextDrawSetString(playerid,PlayerShopBill[playerid],string32);
					        }
				        }
				        else Dialog@Show(playerid,_ERROR,DIALOG_STYLE_MSGBOX,"����[#1]","�������شﵽ����,�޷�����µ���Ʒ������","�˽�","");
			        }
			        return 1;
			    }
                
			}
		}
		forex(i,MAX_SHOP_SHOW_LIST)//-����
		{
		    if(playertextid==PlayerShopListJianBack[playerid][i])
			{
			    if(PlayerShopListShow[playerid]==true)
			    {
                	new pages=PlayerShopPreviePage[playerid]-1;
                	if(pages<1)pages=0;
                	new index=pages*MAX_SHOP_SHOW_LIST+i+1;
                	new Amount=PlayerShopItemAmounts[playerid][PlayerShopPrevieBox[playerid][index]];
                    Amount--;
                	if(Amount>=0)
                	{
           	    		PlayerShopItemAmounts[playerid][PlayerShopPrevieBox[playerid][index]]=Amount;
				        if(PlayerShopListBuyAmount[playerid][i]!=PlayerText:INVALID_TEXT_DRAW)
				        {
				            formatex32("%i",PlayerShopItemAmounts[playerid][PlayerShopPrevieBox[playerid][index]]);
							PlayerTextDrawSetString(playerid,PlayerShopListBuyAmount[playerid][i],string32);
				        }
				        if(PlayerShopBill[playerid]!=PlayerText:INVALID_TEXT_DRAW)
				        {
				            formatex32("%i",GetPlayerBillMoney(playerid));
							PlayerTextDrawSetString(playerid,PlayerShopBill[playerid],string32);
				        }
				        return 1;
			        }
                }
			}
		}
		/***********************************************************************************************/
		forex(i,MAX_PLAYERGLOBALINV_SHOW_LIST)//���ҵ����������ID
		{
		    if(playertextid==PlayerGlobalInvListBg[playerid][i])
			{
			    if(PlayerGlobalInvClickID[playerid]==NONE)
			    {
			        PlayerTextDrawColor(playerid,PlayerGlobalInvListBg[playerid][i], -16777166);
			        PlayerTextDrawShow(playerid,PlayerGlobalInvListBg[playerid][i]);
			        PlayerGlobalInvClickID[playerid]=i;
			    }
			    else
			    {
			        if(PlayerGlobalInvClickID[playerid]!=i)
			        {
				        PlayerTextDrawColor(playerid,PlayerGlobalInvListBg[playerid][PlayerGlobalInvClickID[playerid]], -1094795629);
						PlayerTextDrawShow(playerid,PlayerGlobalInvListBg[playerid][PlayerGlobalInvClickID[playerid]]);
				        PlayerTextDrawColor(playerid, PlayerGlobalInvListBg[playerid][i], -16777166);
				        PlayerTextDrawShow(playerid,PlayerGlobalInvListBg[playerid][i]);
				        PlayerGlobalInvClickID[playerid]=i;
			        }
			    }
				new pages=PlayerGlobalInvPreviePage[playerid]-1;
                if(pages<1)pages=0;
                new index=pages*MAX_PLAYERGLOBALINV_SHOW_LIST+i+1;
                Hooks("OnPlayerClickGlobalInv","ii",playerid,index);
                return 1;
			}
		}
    }
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(Account[playerid][_Login]==true)
	{
	    if(PRESSED(KEY_CTRL_BACK))
	    {
		    if(PlayerGameRoom[playerid][_GameID]!=NONE&&PlayerGameRoom[playerid][_State]>STATE_COMP_SELECT)
		    {
		        ShowPlayerGameConfig(playerid);
		        SelectTextDraw(playerid, 0xFF8500FF);
		    }
	    }
	    if(PRESSED(KEY_YES))
	    {
		    if(PlayerGameRoom[playerid][_GameID]!=NONE&&PlayerGameRoom[playerid][_State]==STATE_PLAYING)
		    {
		        ShowPlayerBuyGunMain(playerid);
		        SelectTextDraw(playerid, 0xFF8500FF);
		    }
	    }
	}
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(Dialog@GetIndex(playerid)!=dialogid)
	{
		formatex128("%s ����ʹ�öԻ�������[%i - %i]",Account[playerid][_Name],Dialog@GetIndex(playerid),dialogid);
        printf(string128);
	    return 1;
	}
	Dialog@Rest(playerid);

    Account@DialogResponse(playerid, dialogid, response, listitem, inputtext);
    GlobalInv@DialogResponse(playerid, dialogid, response, listitem, inputtext);
    GameRoom@DialogResponse(playerid, dialogid, response, listitem, inputtext);
	return 1;
}




public OnPlayerConnect(playerid)
{
    RestDownLoadArt(playerid);
    SetPlayerScore(playerid,0);
    RestAccountDate(playerid);
    
    RestPlayerGameWeapons(playerid);

    PlayerGlobalInvRest(playerid);
    
    GetPlayerNameEx(playerid,Account[playerid][_Name],64);
    
    CreatePlayerHealthBar(playerid,100.0);
	return 1;
}
public OnPlayerDisconnect(playerid,reason)
{
    RestPlayerRoomListDraws(playerid,true);
    RestPlayerAccountPanelDraws(playerid,true);
    RestPlayerLevelDraws(playerid,true);
    RestPlayerGlobalInvDraws(playerid,true);
    RestPlayerPlayerDownLoadDraws(playerid,true);
    RestPlayerShopDraws(playerid,true,true);
    RestPlayerErrorBoxDraws(playerid,true);
    RestPlayerCreateRoomDraws(playerid,true);
    RestAccountDate(playerid);
    RestDownLoadArt(playerid);
 	DestoryPlayerHealthBar(playerid);
 	RestPlayerGameRoomData(playerid,true);
 	
    PlayerGlobalInvRest(playerid);
    
    RestPlayerGameWeapons(playerid);
 	return 1;
}
N::ClearChat(playerid)
{
	forex(i,30)SendClientMessage(playerid,-1, " ");
	return 1;
}
public OnPlayerSpawn(playerid)
{
	printf("OnPlayerSpawn");
    SetPlayerVirtualWorld(playerid,PLAYER_INTFACE_WORLD+playerid);
    TogglePlayerControllable(playerid,0);
    ClearChat(playerid);
	if(Account[playerid][_Login]==false)
    {
		Account@GetAccountInfo(playerid);
    }
    else
    {
        if(PlayerGameRoom[playerid][_GameID]!=NONE)
        {
            RestPlayerGameRoomData(playerid,true);
			SetPlayerTime(playerid,12,0);
			SetPlayerWeather(playerid,20);
			
		    SetPlayerPos(playerid,-561.8014,465.1385,114.7091);
		    SetPlayerFacingAngle(playerid,Account[playerid][_FaceAngle]);
			SetPlayerCameraPos(playerid,-559.05,463.9912,114.7091);
			SetPlayerCameraLookAt(playerid,-561.8014,463.9912,114.7091,CAMERA_CUT);
			
			ShowPlayerRoomBackGround(playerid);
			CreatePlayerRoomPage(playerid,1);
		    ShowPlayerAccountPanel(playerid,true);
		    ShowPlayerLevelDraws(playerid);
        }
		else
		{
		}
    }
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
    printf("OnPlayerDeath");
    RestAccountDate(playerid);
   	return 1;
}
N::AutoSpawnPlayer(playerid)
{
 	SetSpawnInfo(playerid,NO_TEAM,Skins[1][_Mod@Skin],-561.8014,465.1385,114.7091,277.2332,0,0,0,0,0,0);
   	TogglePlayerSpectating(playerid,false);
   	Account[playerid][Timer:_SpawnTimer]=NONE;
   	return 1;
}
public OnPlayerRequestClass(playerid, classid)
{
    printf("OnPlayerRequestClass");
	if(Account[playerid][_Login]==false)
	{
	    //ClearChat(playerid);
		TogglePlayerSpectating(playerid,true);
		//CreateAmmoTextDraw(playerid);
		/*TextDrawShowForPlayer(playerid,LoadingInterFaceBackGround);
		TextDrawShowForPlayer(playerid,LoadingInterFaceText);
		Account[playerid][Timer:_SpawnTimer]=SetTimerEx("AutoSpawnPlayer",3000, false, "i", playerid);*/
    }
	return 1;
}

CMD:an(playerid, params[], help)
{
	SetPlayerFacingAngle(playerid,random(360));
	SCM(playerid,-1,"�ɹ�");
	return 1;
}
CMD:level(playerid, params[], help)
{
	new change;
	if(sscanf(params, "i",change))return SCM(playerid,-1,"����");
	PlayerLevelUpdate(playerid,change);
	return 1;
}
CMD:kill(playerid, params[], help)
{
	DamagePlayer(playerid,1000);
	return 1;
}

public OnPlayerUpdate(playerid)
{
    if(Account[playerid][_Login]==true)
    {
    }
    if(PlayerLevelTextDrawShow[playerid]==true)
    {
		if(PlayerClickRotMode[playerid]!=0)
		{
		    new Float:FaceAngle;
			switch(PlayerClickRotMode[playerid])
			{
			    case 1:
			    {
					FaceAngle=floatsub(Account[playerid][_FaceAngle],1.0);
					Account[playerid][_FaceAngle]=FaceAngle;
					if(Account[playerid][_FaceAngle]<0.0)
					{
						Account[playerid][_FaceAngle]=0.0;
						Update@AccountFaceAngle(playerid,Account[playerid][_FaceAngle]);
						PlayerClickRotMode[playerid]=0;
	                	if(PlayerRightRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerRightRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerRightRotArrow[playerid]);
	                	if(PlayerLeftRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerLeftRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerLeftRotArrow[playerid]);
					}
					SetPlayerFacingAngle(playerid,Account[playerid][_FaceAngle]);
			    }
			    case 2:
			    {
					FaceAngle=floatadd(Account[playerid][_FaceAngle],1.0);
					Account[playerid][_FaceAngle]=FaceAngle;
					if(Account[playerid][_FaceAngle]>360.0)
					{
						Account[playerid][_FaceAngle]=360.0;
						Update@AccountFaceAngle(playerid,Account[playerid][_FaceAngle]);
						PlayerClickRotMode[playerid]=0;
	                	if(PlayerRightRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerRightRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerRightRotArrow[playerid]);
	                	if(PlayerLeftRotArrow[playerid]!=PlayerText:INVALID_TEXT_DRAW)PlayerTextDrawColor(playerid, PlayerLeftRotArrow[playerid], -256);PlayerTextDrawShow(playerid, PlayerLeftRotArrow[playerid]);
					}
					SetPlayerFacingAngle(playerid,Account[playerid][_FaceAngle]);
			    }
			}
		}
	}
	else PlayerClickRotMode[playerid]=0;
	return 1;
}

