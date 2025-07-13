import fs from 'fs/promises'
import path from 'path'
import { Theme } from '@/types'

const THEMES_DIR = './themes'
const THEMES_JSON = './themes/themes.json'

export async function ensureThemesDirectory() {
  try {
    await fs.access(THEMES_DIR)
  } catch {
    await fs.mkdir(THEMES_DIR, { recursive: true })
  }
}

export async function loadThemes(): Promise<Theme[]> {
  try {
    await ensureThemesDirectory()
    const data = await fs.readFile(THEMES_JSON, 'utf-8')
    return JSON.parse(data)
  } catch {
    return []
  }
}

export async function saveThemes(themes: Theme[]): Promise<void> {
  await ensureThemesDirectory()
  await fs.writeFile(THEMES_JSON, JSON.stringify(themes, null, 2))
}

export async function addTheme(theme: Theme): Promise<void> {
  const themes = await loadThemes()
  themes.push(theme)
  await saveThemes(themes)
}

export async function getThemeById(id: string): Promise<Theme | null> {
  const themes = await loadThemes()
  return themes.find(theme => theme.id === id) || null
}
