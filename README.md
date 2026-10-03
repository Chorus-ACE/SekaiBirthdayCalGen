# SekaiBirthdayCalGen

A Project Sekai adaptation of [Chorus-ACE/BirthdayCalGen](https://github.com/Chorus-ACE/BirthdayCalGen), retaining its Swift calendar builder and localized annual birthday events.

Requires Xcode and the adjacent `../SekaiKit` Swift package. The Xcode project references SekaiKit directly; a separate workspace and DoriKit are no longer needed.

```sh
mkdir -p calendars
./generate.sh --output calendars
```

The script builds the command-line tool and generates `BirthdayCalendar_jp.ics`, `BirthdayCalendar_en.ics`, `BirthdayCalendar_tw.ics`, `BirthdayCalendar_cn.ics`, and `BirthdayCalendar_kr.ics` using SekaiKit's character and event data. Names follow each region. Characters without a birthday or a regional name are omitted.

The six Virtual Singers (Miku, Rin, Len, Luka, MEIKO, and KAITO; character IDs 21–26) use anniversary wording in event titles, reminder descriptions, and categories in all five languages: 記念日, Anniversary, 紀念日, 纪念日, and 기념일. Other characters retain birthday wording.

Each birthday or anniversary is an all-day, yearly recurring, transparent event with stable character/locale identifiers. The first occurrence follows the first Japanese event featuring that character, falling back to the Japanese game launch date. As in the original generator, reminders fire one day before and on the birthday. All-day dates follow the subscribing calendar's local day, independently of GreatSekai's Birthday Time Zone setting.

For reproducible offline generation from SekaiKit's protobuf archives:

```sh
./generate.sh --output calendars --data-directory /path/to/archives
```

The archive directory must contain `character.aar` and `event.aar`. Failed or empty source loads stop generation instead of writing empty calendars. Set `BIRTHDAY_BUILD_DIR` to reuse another Xcode build directory.

This adaptation also fixes UTC timestamp conversion, adds required display-alarm descriptions, escapes calendar text, and folds lines at 75 UTF-8 octets.
