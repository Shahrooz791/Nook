# Nook

A notes app for Gen Z — with a secret vault hidden inside.

## What Nook Is

On the surface, Nook is a simple, clean notes app. You write a note, and you can optionally lock it to a future date — the note stays sealed and unreadable until that date arrives, at which point it automatically unlocks and becomes readable again. A small, calm daily habit: write, lock (or don't), and let time do the rest.

That's the entire experience for anyone who just opens the app and starts using it.

## The Hidden Vault

Hold down on the **Add Note** button, and instead of creating a new note, Nook takes you somewhere else entirely: a PIN setup screen for a completely separate, hidden vault.

Once the PIN is set (and on every visit after that), this same gesture opens a fully encrypted, offline vault — invisible to anyone who doesn't know the gesture exists.

### What the vault does

The vault's whole purpose is to let users **hide their own personal data**, fully offline, with nothing stored anywhere but the device itself:

- **Photos & Videos** — import directly from your device gallery. Once imported, the originals are properly removed from the gallery, not just copied — the data is actually hidden, not duplicated.
- **Documents** — import files from your device the same way.
- **Notes** — a separate, private notes space inside the vault, distinct from the public notes on the home screen.
- **Passwords** — save login details for your accounts (e.g. Instagram, LinkedIn, TikTok) — account name, username/description, and password, all encrypted.
- **Change PIN** — update your vault PIN whenever you want.
- **Wipe All Data** — permanently delete everything in the vault in one action, for when you want a clean slate.
- **Restore** — change your mind about something you hid? Restore brings a photo, video, or document back out of the vault and saves it into a **"NookRestored"** folder in your device's gallery, so you get it back in a normal, accessible location.

### Fully local, fully private

Nook doesn't use any backend, server, or cloud storage of any kind. Every piece of data — public notes, vault photos, videos, documents, notes, and passwords — lives entirely on the device:

- Local structured data storage for notes and vault metadata
- Vault contents are encrypted before they're ever written to disk
- Everything is retrievable only from within the app, only after unlocking the vault

Nothing is ever sent anywhere. What's on the device stays on the device.

## Tech Stack

- **Flutter**
- **GetX** — state management and navigation throughout the app
- Local on-device database for notes and vault metadata
- On-device encrypted file storage for vault contents (photos, videos, documents)
- Secure, OS-level storage for the vault's PIN/encryption key
- Native gallery integration for importing photos/videos and properly removing the originals once hidden

## Why This App Exists

Most note-taking and journaling apps don't offer any real way to keep sensitive personal content — private photos, videos, documents, or account passwords — properly hidden and secure on the same device. Nook was built specifically to fill that gap for a Gen Z audience: a normal-looking, genuinely useful notes app on the surface, with a real, properly encrypted, fully local vault underneath for anyone who wants to keep certain things just for themselves.!
