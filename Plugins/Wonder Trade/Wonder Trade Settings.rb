#===============================================================================
# Wonder Trade
# By Dr.Doom76
#===============================================================================
module WonderTradeSettings
 # This is a list of Blocklisted Pokemon. These Pokemon will be considered for trade.
 # Format is [:POKEMON1, :POKEMON2]
 USE_BLOCKLIST = false
 
 BLOCKLIST_POKEMON = []
 
 # This is a list of Allowlisted Pokemon. These Pokemon will be pushed into the trade pool.
 # The first thing is the species of the Pokemon you want an extra "chance" of getting.
 # The second thing is the number of "chances" you wish to add.
 # The higher the number, the lower the rarity is going to be.
 # Format is as follows:
 #ALLOWLIST_POKEMON = {
 # :MELOETTA => 5,
 # :RATTATA => 10,
 # :PIKACHU => 30
 #  }

 USE_ALLOWLIST = false

 ALLOWLIST_POKEMON = {

}
 
 # Setting for Male and Female names. Names are randomly selected from one of the listed, if not otherwised defined.
 MALE_NAMES = [
  "James",
  "John",
  "Robert",
  "Michael",
  "William",
  "David",
  "Joseph",
  "Charles",
  "Thomas",
  "Daniel",
  "Christopher",
  "Matthew",
  "Mark",
  "Brian",
  "Kevin",
  "Anthony",
  "Steven",
  "Andrew",
  "Richard",
  "Paul",
  "Kenneth",
  "Timothy",
  "Jason",
  "Jeffrey",
  "Scott",
  "Eric",
  "Stephen",
  "Larry",
  "Frank",
  "Benjamin",
  "Patrick",
  "Adam",
  "Timothy",
  "Philip",
  "Jeremy",
  "Travis",
  "Joshua",
  "Jonathan",
  "Justin",
  "Terry",
  "Austin",
  "Brandon",
  "Samuel",
  "Zachary",
  "Sean",
  "Raymond",
  "Donald",
]

FEMALE_NAMES = [
  "Mary",
  "Patricia",
  "Linda",
  "Elizabeth",
  "Susan",
  "Jessica",
  "Sarah",
  "Karen",
  "Nancy",
  "Lisa",
  "Betty",
  "Dorothy",
  "Sandra",
  "Ashley",
  "Kimberly",
  "Donna",
  "Carol",
  "Michelle",
  "Emily",
  "Amanda",
  "Helen",
  "Melissa",
  "Deborah",
  "Stephanie",
  "Laura",
  "Rebecca",
  "Sharon",
  "Cynthia",
  "Kathleen",
  "Amy",
  "Shirley",
  "Angela",
  "Teresa",
  "Rachel",
  "Gloria",
  "Evelyn",
  "Diane",
  "Virginia",
  "Janet",
  "Pamela",
  "Marie",
  "Frances",
  "Judy",
  "Christina",
  "Martha",
  "Andrea",
  "Debra",
]

# Settings for nick names. If true, it will randomly assign a nickname from the list below, if a nickname is not passed through an argument.
USE_NICKNAME = false

POKEMON_NICKNAMES = [
  "Bolt",
  "Flare",
  "Aqua",
  "Spike",
  "Shadow",
  "Breeze",
  "Blaze",
  "Luna",
  "Sunny",
  "Rumble",
  "Sparky",
  "Misty",
  "Rocky",
  "Frosty",
  "Whisper",
  "Glimmer",
  "Rusty",
  "Buddy",
  "Cinder",
  "Zephyr",
  "Nova",
  "Echo",
  "Fang",
  "Frost",
  "Pebble",
  "Specter",
  "Sapphire",
  "Dusty",
  "Ember",
  "Pebble",
  "Dusk",
  "Breezy",
  "Aurora",
  "Rusty",
  "Lunar",
  "Mystic",
  "Sparrow",
  "Thunder",
  "Blizzard",
  "Shadow",
  "Dawn",
  "Boulder",
  "Storm",
  "Whisper",
  "Smokey",
  "Crimson",
  "Buddy",
  "Glider",
  "Aurora",
]

 end
 
 