# Player Stats Menu & Character Progression Guide

## What is this system?
The Player Stats Menu is like your character sheet in an RPG game! It shows all your character's abilities and how they improve over time. Every time you catch a fish, your character gets a tiny bit stronger, making you better at fishing.

## 🎯 How to Open the Player Stats Menu

### Step-by-Step Instructions
1. **Start fishing**: Enter any fishing area in the game
2. **Look for the button**: Find the "Player Stats" button next to the "Back" button on your screen
3. **Click to open**: Click the "Player Stats" button to see your character information
4. **Close the menu**: Click "Close" or press the ESC key when you're done

### What You'll See
The menu shows up as a dark window in the center of your screen with two sections:

**Left Side - Your Character Info:**
- Your character picture
- Four main stats (Strength, Speed, Vitality, Luck)
- Energy information
- How much money you have

**Right Side - Active Effects:**
- Special potions you've used
- Temporary bonuses
- Shows "No active buffs" when nothing is active

## 🐟 How Character Growth Works

### The Simple Explanation
Think of it like gaining experience points (XP) in other games, but instead of fighting monsters, you catch fish! Every fish you catch makes you slightly stronger.

### What Each Stat Does

#### 🏋️ Strength
- **What it does**: Makes it easier to catch fish and pull them in
- **How it helps**: Stronger characters can catch difficult fish more easily
- **You'll notice**: Fish struggle less when you hook them

#### ⚡ Speed  
- **What it does**: Makes you move faster and fish faster
- **How it helps**: You can move around quicker and catch fish faster
- **You'll notice**: Your character and fishing rod work faster

#### ❤️ Vitality
- **What it does**: Gives you more energy and uses less energy per fish
- **How it helps**: You can fish longer without getting tired
- **You'll notice**: Your energy bar is bigger and drains slower

#### 🍀 Luck
- **What it does**: Helps you find rare and valuable fish
- **How it helps**: Better chance of catching epic and legendary fish
- **You'll notice**: You'll see more colorful, rare fish swimming around

## 🎣 How to Get Stronger (Fish-Based Progression)

### The Basic Rule
**Catch fish = Get stronger!** It's that simple!

### Different Fish Give Different Rewards

| Fish Type | How Much Stronger You Get | Fish Needed for +1 Strength |
|-----------|---------------------------|------------------------------|
| **Common** (Gray) | Very small boost | 200 fish |
| **Uncommon** (Green) | Small boost | 100 fish |
| **Rare** (Blue) | Medium boost | 67 fish |
| **Epic** (Purple) | Large boost | 50 fish |
| **Legendary** (Gold) | Huge boost | 40 fish |

### Understanding Progress Percentages
Next to each stat, you'll see a percentage like "(23.5%)" - this shows how close you are to getting your next full stat point!

**Example**: "Strength: 4 (23.5%)" means:
- You currently have 4 strength points
- You're 23.5% of the way to getting your 5th strength point
- You need to catch more fish to reach 100% and gain the next level

## 🎮 Beginner Tips

### Getting Started
1. **Start with any fish**: Even common gray fish help you grow stronger
2. **Check your progress**: Open the stats menu after catching several fish to see your improvement
3. **Don't worry about perfection**: Every fish caught is progress toward becoming stronger

### Smart Fishing Strategy
1. **Catch everything**: All fish contribute to your growth
2. **Look for rare fish**: Colorful fish (blue, purple, gold) give bigger bonuses
3. **Be patient**: Character growth takes time, but it's permanent
4. **Use potions wisely**: Potions can help you catch more fish faster

### What the Colors Mean
The menu uses different colors to help you understand information quickly:

- **Yellow headers**: Section titles (like "Base Stats")
- **White text**: Your main character information  
- **Cyan/Blue**: Energy and fish-slowing effects
- **Green**: Speed bonuses from potions
- **Orange**: Rod improvement effects
- **Gold**: Your money amount
- **Gray**: When no special effects are active

## 🔄 Why This System is Great for Beginners

### Every Action Matters
- No fish catch is "wasted" - they all help you grow
- You can't lose progress - all improvements are permanent
- The game gets more fun as you get stronger

### Clear Goals
- You can see exactly how close you are to the next improvement
- Progress is always visible in the stats menu
- Long-term goals keep you motivated to keep playing

### Gradual Learning
- Start simple by just catching any fish
- Learn about rare fish as you encounter them
- Develop strategies as you understand the system better

## 💾 Your Progress is Saved Automatically

### Don't Worry About Losing Progress
- All your character improvements are saved automatically
- Your stats carry over between different fishing areas
- Even if you close the game, your progress remains
- No need to manually save - the game does it for you

## 🚀 Advanced Tips (For When You're Ready)

### Targeting Specific Fish Types
- If you want faster strength gains, focus on catching rare fish (blue, purple, gold)
- Common fish are easier to catch but give smaller bonuses
- Epic and Legendary fish are challenging but give the biggest rewards

### Using the Progression System Strategically
- Higher strength makes it easier to catch rare fish
- This creates a positive cycle: strong → catch rare fish → get stronger faster
- Luck helps you find more rare fish to catch

### Understanding the Numbers
- The actual strength gain per fish is very small (0.1% of the fish's strength value)
- This means 1000 strength points from fish = 1 character strength point
- Don't worry about the math - just focus on catching fish and watching your progress grow!

## 🎪 What Makes This System Fun

### Immediate Feedback
- Console messages show you exactly what you gained from each fish
- Progress percentages update in real-time
- You can see your character getting stronger over time

### Long-Term Rewards
- Every fishing session contributes to permanent character growth
- The stronger you get, the more fun and easier fishing becomes
- Rare fish become more achievable as your stats improve

### No Pressure Gameplay
- There's no "wrong" way to play - all fishing helps
- You can take breaks and come back anytime
- Progress is always moving forward, never backward

Remember: The most important thing is to have fun fishing! The character progression happens naturally as you play, so just focus on enjoying the fishing experience and watching your character grow stronger over time.

## 🔧 Technical Details (For Curious Players)

If you're interested in how the system works behind the scenes:

### How Strength Gain is Calculated
```
Fish Strength Values:
- Common: 5 strength
- Uncommon: 10 strength  
- Rare: 15 strength
- Epic: 20 strength
- Legendary: 25 strength

Player Gain Formula: Fish Strength × 0.001
(This means you get 0.1% of the fish's strength as your gain)
```

### File Locations in Code
- **Player.gd**: Contains all player stat management
- **Rod.gd**: Handles giving strength when fish are caught
- **GlobalVariable.gd**: Stores all player progress permanently
- **SaveManager.gd**: Automatically saves all progress
- **PlayerStatsMenu.gd**: Displays the stats menu interface
