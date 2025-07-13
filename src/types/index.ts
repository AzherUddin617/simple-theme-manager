export interface Theme {
  id: string
  name: string
  version: string
  developer: string
  description: string
  filename: string
  uploadDate: string
  fileSize: number
}

export interface ThemePresetFile {
  path: string
  content: string
}
