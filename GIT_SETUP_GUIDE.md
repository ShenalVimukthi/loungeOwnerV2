# Git Repository Setup Guide

This guide will help you create a Git repository for your Lounge Owner Flutter app and push it to GitHub.

## Prerequisites

- Git installed on your computer ([Download Git](https://git-scm.com/downloads))
- GitHub account ([Sign up here](https://github.com))

## Step 1: Initialize Git Repository

Open PowerShell in your project directory and run:

```powershell
cd e:\lounge_app\lounge-owner
git init
```

This creates a new Git repository in your project folder.

## Step 2: Configure Git (First Time Only)

If you haven't set up Git before, configure your name and email:

```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## Step 3: Create .gitignore File

A `.gitignore` file is already present in Flutter projects, but verify it includes these entries:

```
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
flutter_*.png

# Android
android/**/gradle-wrapper.jar
android/.gradle
android/captures/
android/gradlew
android/gradlew.bat
android/local.properties
android/**/GeneratedPluginRegistrant.java
android/key.properties
*.jks

# iOS
ios/**/*.mode1v3
ios/**/*.mode2v3
ios/**/*.moved-aside
ios/**/*.pbxuser
ios/**/*.perspectivev3
ios/**/*sync/
ios/**/.sconsign.dblite
ios/**/.tags*
ios/**/.vagrant/
ios/**/DerivedData/
ios/**/Icon?
ios/**/Pods/
ios/**/.symlinks/
ios/**/profile
ios/**/xcuserdata
ios/.generated/
ios/Flutter/App.framework
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/Generated.xcconfig
ios/Flutter/ephemeral
ios/Flutter/app.flx
ios/Flutter/app.zip
ios/Flutter/flutter_assets/
ios/Flutter/flutter_export_environment.sh
ios/ServiceDefinitions.json
ios/Runner/GeneratedPluginRegistrant.*

# Web
web/

# Windows
windows/flutter/ephemeral/

# Coverage
coverage/

# Exceptions (files to keep)
!**/ios/**/default.mode1v3
!**/ios/**/default.mode2v3
!**/ios/**/default.pbxuser
!**/ios/**/default.perspectivev3

# Sensitive files
*.env
*.env.local
local.properties
android/key.properties

# IDE
.vscode/
.idea/
*.iml
*.ipr
*.iws
.DS_Store
```

## Step 4: Stage Your Files

Add all files to the staging area:

```powershell
git add .
```

Check what will be committed:

```powershell
git status
```

## Step 5: Create First Commit

Commit your files with a meaningful message:

```powershell
git commit -m "Initial commit: Lounge Owner Flutter app"
```

## Step 6: Create GitHub Repository

### Option A: Using GitHub Website

1. Go to [GitHub](https://github.com)
2. Click the **+** icon in the top-right corner
3. Select **New repository**
4. Fill in the details:
   - **Repository name**: `lounge-owner-app` (or your preferred name)
   - **Description**: "Flutter application for lounge owners to manage staff and transportation services"
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
5. Click **Create repository**

### Option B: Using GitHub CLI (if installed)

```powershell
gh repo create lounge-owner-app --private --source=. --remote=origin
```

## Step 7: Connect Local Repository to GitHub

After creating the repository on GitHub, you'll see commands. Use these:

```powershell
# Add remote repository
git remote add origin https://github.com/YOUR_USERNAME/lounge-owner-app.git

# Verify remote was added
git remote -v
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 8: Push to GitHub

### First Time Push

```powershell
# Rename default branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

### Subsequent Pushes

After the first push, you can simply use:

```powershell
git push
```

## Step 9: Verify Upload

1. Go to your GitHub repository: `https://github.com/YOUR_USERNAME/lounge-owner-app`
2. Refresh the page
3. Verify all files are uploaded

## Common Git Commands for Future Use

### Checking Status
```powershell
git status
```

### Adding Changes
```powershell
# Add specific file
git add path/to/file.dart

# Add all changed files
git add .
```

### Committing Changes
```powershell
git commit -m "Your commit message"
```

### Pushing Changes
```powershell
git push
```

### Pulling Latest Changes
```powershell
git pull
```

### Creating a New Branch
```powershell
git checkout -b feature/new-feature-name
```

### Switching Branches
```powershell
git checkout main
git checkout feature/branch-name
```

### Viewing Commit History
```powershell
git log
git log --oneline
```

### Viewing Changes
```powershell
# See unstaged changes
git diff

# See staged changes
git diff --staged
```

## Best Practices

### 1. **Commit Often**
- Make small, focused commits
- Each commit should represent one logical change

### 2. **Write Clear Commit Messages**
```
Good examples:
- "Add transport location management feature"
- "Fix: Resolve latitude/longitude validation error"
- "Update: Change API endpoint for staff registration"

Bad examples:
- "fixed stuff"
- "update"
- "changes"
```

### 3. **Use Branches for Features**
```powershell
# Create and switch to new branch
git checkout -b feature/staff-management

# Work on your feature...

# Push branch to GitHub
git push -u origin feature/staff-management
```

### 4. **Don't Commit Sensitive Data**
- Never commit API keys, passwords, or secrets
- Use `.env` files and add them to `.gitignore`
- Use `local.properties` for Android secrets

### 5. **Pull Before Push**
```powershell
git pull
git push
```

## Troubleshooting

### Authentication Error

If you get authentication errors when pushing:

1. **Use Personal Access Token (PAT)** instead of password:
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `repo` scope
   - Use token as password when prompted

2. **Or use SSH**:
   ```powershell
   # Generate SSH key
   ssh-keygen -t ed25519 -C "your.email@example.com"
   
   # Add to GitHub: Settings → SSH and GPG keys → New SSH key
   # Change remote URL
   git remote set-url origin git@github.com:YOUR_USERNAME/lounge-owner-app.git
   ```

### Large File Error

If you accidentally committed large files:

```powershell
# Remove file from Git but keep locally
git rm --cached path/to/large/file

# Add to .gitignore
echo "path/to/large/file" >> .gitignore

# Commit the change
git commit -m "Remove large file from repository"
```

### Undo Last Commit (Not Pushed)

```powershell
# Keep changes but undo commit
git reset --soft HEAD~1

# Discard changes completely
git reset --hard HEAD~1
```

## Quick Reference Commands

```powershell
# Initialize repository
git init

# Check status
git status

# Add all files
git add .

# Commit with message
git commit -m "message"

# Add remote
git remote add origin https://github.com/USERNAME/REPO.git

# Push to GitHub
git push -u origin main

# Pull from GitHub
git pull

# Create branch
git checkout -b branch-name

# Switch branch
git checkout branch-name

# Merge branch
git merge branch-name

# View log
git log --oneline
```

## Next Steps

After setting up Git:

1. **Set up branch protection** on GitHub (Settings → Branches)
2. **Add collaborators** if working in a team
3. **Create a README.md** with project documentation
4. **Set up GitHub Actions** for CI/CD (optional)
5. **Use GitHub Issues** for bug tracking

---

## Additional Resources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Guides](https://guides.github.com/)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Flutter Git Best Practices](https://docs.flutter.dev/deployment/cd)

---

**Happy Coding! 🚀**
