#!/bin/bash

# Simple Theme Manager Setup Script
# No database required - just local file storage!

echo "🎨 Simple Theme Manager Setup"
echo "=============================="
echo ""

# Check if we're in the right place
if [ ! -f "package.json" ]; then
    echo "❌ Error: No package.json found. Please run this in your Next.js project directory."
    echo "💡 Tip: Run 'npx create-next-app@latest simple-theme-manager --typescript --tailwind' first"
    exit 1
fi

echo "📦 Step 1: Installing dependencies..."
npm install adm-zip formidable lucide-react
npm install -D @types/adm-zip @types/formidable

echo ""
echo "📁 Step 2: Creating directory structure..."
mkdir -p src/app/api/upload-theme
mkdir -p src/app/api/themes
mkdir -p src/app/api/download-theme
mkdir -p src/app/api/download-preset
mkdir -p src/lib
mkdir -p src/types
mkdir -p themes

echo ""
echo "🗂️ Step 3: Creating type definitions..."
cat > src/types/index.ts << 'EOF'
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
EOF

echo ""
echo "💾 Step 4: Creating file storage utilities..."
cat > src/lib/file-storage.ts << 'EOF'
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
EOF

echo ""
echo "🎨 Step 5: Creating theme preset generator..."
cat > src/lib/theme-presets.ts << 'EOF'
import { ThemePresetFile } from '@/types'

export function generateThemePreset(): ThemePresetFile[] {
  return [
    {
      path: 'components/Header.tsx',
      content: `import React from 'react';

interface HeaderProps {
  logo?: string;
  navigation?: Array<{ label: string; href: string }>;
  showSearch?: boolean;
}

const Header: React.FC<HeaderProps> = ({ 
  logo = '/logo.svg', 
  navigation = [],
  showSearch = true 
}) => {
  return (
    <header className="bg-white shadow-md sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center">
            <img src={logo} alt="Logo" className="h-8 w-auto" />
          </div>
          
          <nav className="hidden md:flex space-x-8">
            {navigation.map((item, index) => (
              <a
                key={index}
                href={item.href}
                className="text-gray-700 hover:text-blue-600 transition-colors font-medium"
              >
                {item.label}
              </a>
            ))}
          </nav>
          
          {showSearch && (
            <div className="flex items-center space-x-4">
              <input
                type="text"
                placeholder="Search products..."
                className="px-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 w-64"
              />
              <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
                Search
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;`
    },
    {
      path: 'components/Footer.tsx',
      content: `import React from 'react';

interface FooterProps {
  companyName?: string;
  year?: number;
}

const Footer: React.FC<FooterProps> = ({ 
  companyName = 'Your Store',
  year = new Date().getFullYear()
}) => {
  return (
    <footer className="bg-gray-900 text-white">
      <div className="container mx-auto px-4 py-12">
        <div className="text-center">
          <h3 className="text-lg font-semibold mb-4">{companyName}</h3>
          <p className="text-gray-400 mb-8">
            Your trusted online store for quality products.
          </p>
          <div className="border-t border-gray-800 pt-8">
            <p className="text-gray-400">
              © {year} {companyName}. All rights reserved.
            </p>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;`
    },
    {
      path: 'components/ProductGrid.tsx',
      content: `import React from 'react';

interface Product {
  id: string;
  name: string;
  price: number;
  image: string;
}

interface ProductGridProps {
  products: Product[];
  onProductClick?: (product: Product) => void;
}

const ProductGrid: React.FC<ProductGridProps> = ({ products, onProductClick }) => {
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
      {products.map((product) => (
        <div
          key={product.id}
          className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow cursor-pointer"
          onClick={() => onProductClick?.(product)}
        >
          <div className="aspect-square bg-gray-100">
            <img
              src={product.image}
              alt={product.name}
              className="w-full h-full object-cover"
            />
          </div>
          <div className="p-4">
            <h3 className="text-lg font-semibold text-gray-900 mb-2">
              {product.name}
            </h3>
            <p className="text-xl font-bold text-blue-600">
              \${product.price.toFixed(2)}
            </p>
          </div>
        </div>
      ))}
    </div>
  );
};

export default ProductGrid;`
    },
    {
      path: 'styles/globals.css',
      content: `@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .btn-primary {
    @apply bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors;
  }
  
  .card {
    @apply bg-white rounded-lg shadow-md p-6;
  }
}

.animate-fade-in {
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}`
    },
    {
      path: 'README.md',
      content: `# Simple Theme Preset

A basic e-commerce theme with React components.

## Components
- Header with navigation and search
- Footer with company info
- Product grid layout

## Usage
Customize these components for your store!`
    }
  ]
}
EOF

echo ""
echo "🔌 Step 6: Creating API routes..."

# Upload theme API
cat > src/app/api/upload-theme/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { writeFile } from 'fs/promises'
import path from 'path'
import { Theme } from '@/types'
import { addTheme, ensureThemesDirectory } from '@/lib/file-storage'

export async function POST(request: NextRequest) {
  try {
    await ensureThemesDirectory()

    const formData = await request.formData()
    const file = formData.get('themeFile') as File
    const themeName = formData.get('themeName') as string
    const themeVersion = formData.get('themeVersion') as string
    const developerName = formData.get('developerName') as string
    const description = formData.get('description') as string

    if (!file || !themeName || !themeVersion || !developerName || !description) {
      return NextResponse.json({ 
        success: false, 
        error: 'All fields are required' 
      }, { status: 400 })
    }

    const themeId = Date.now().toString()
    const fileExtension = path.extname(file.name)
    const filename = `theme_${themeId}${fileExtension}`
    const filePath = path.join('./themes', filename)

    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    await writeFile(filePath, buffer)

    const theme: Theme = {
      id: themeId,
      name: themeName,
      version: themeVersion,
      developer: developerName,
      description,
      filename,
      uploadDate: new Date().toISOString(),
      fileSize: file.size
    }

    await addTheme(theme)

    return NextResponse.json({
      success: true,
      message: 'Theme uploaded successfully',
      themeId
    })

  } catch (error) {
    console.error('Upload error:', error)
    return NextResponse.json({ 
      success: false, 
      error: 'Upload failed' 
    }, { status: 500 })
  }
}
EOF

# Get themes API
cat > src/app/api/themes/route.ts << 'EOF'
import { NextResponse } from 'next/server'
import { loadThemes } from '@/lib/file-storage'

export async function GET() {
  try {
    const themes = await loadThemes()
    return NextResponse.json({ success: true, themes })
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: 'Failed to load themes' 
    }, { status: 500 })
  }
}
EOF

# Download theme API
mkdir -p src/app/api/download-theme/\[id\]
cat > src/app/api/download-theme/\[id\]/route.ts << 'EOF'
import { NextRequest, NextResponse } from 'next/server'
import { readFile } from 'fs/promises'
import path from 'path'
import { getThemeById } from '@/lib/file-storage'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const theme = await getThemeById(params.id)
    
    if (!theme) {
      return NextResponse.json({ 
        success: false, 
        error: 'Theme not found' 
      }, { status: 404 })
    }

    const filePath = path.join('./themes', theme.filename)
    const fileBuffer = await readFile(filePath)

    return new NextResponse(fileBuffer, {
      status: 200,
      headers: {
        'Content-Type': 'application/zip',
        'Content-Disposition': `attachment; filename="${theme.filename}"`,
      }
    })

  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: 'Download failed' 
    }, { status: 500 })
  }
}
EOF

# Download preset API
cat > src/app/api/download-preset/route.ts << 'EOF'
import { NextResponse } from 'next/server'
import AdmZip from 'adm-zip'
import { generateThemePreset } from '@/lib/theme-presets'

export async function GET() {
  try {
    const presetFiles = generateThemePreset()
    const zip = new AdmZip()
    
    for (const file of presetFiles) {
      zip.addFile(file.path, Buffer.from(file.content, 'utf8'))
    }
    
    const zipBuffer = zip.toBuffer()
    
    return new NextResponse(zipBuffer, {
      status: 200,
      headers: {
        'Content-Type': 'application/zip',
        'Content-Disposition': 'attachment; filename="theme-preset.zip"',
      }
    })
    
  } catch (error) {
    return NextResponse.json({ 
      success: false, 
      error: 'Failed to generate preset' 
    }, { status: 500 })
  }
}
EOF

echo ""
echo "🏠 Step 7: Creating main admin page..."
cat > src/app/page.tsx << 'EOF'
'use client'

import React, { useState, useEffect } from 'react'
import { Upload, Download, Calendar, User, Package } from 'lucide-react'
import { Theme } from '@/types'

export default function AdminPage() {
  const [themes, setThemes] = useState<Theme[]>([])
  const [loading, setLoading] = useState(true)
  const [uploading, setUploading] = useState(false)
  const [downloadingPreset, setDownloadingPreset] = useState(false)
  
  const [formData, setFormData] = useState({
    themeName: '',
    themeVersion: '',
    developerName: '',
    description: ''
  })
  const [file, setFile] = useState<File | null>(null)
  const [uploadResult, setUploadResult] = useState<string | null>(null)

  useEffect(() => {
    fetchThemes()
  }, [])

  const fetchThemes = async () => {
    try {
      const response = await fetch('/api/themes')
      const result = await response.json()
      if (result.success) {
        setThemes(result.themes)
      }
    } catch (error) {
      console.error('Failed to fetch themes:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleFileSelect = (selectedFile: File) => {
    if (selectedFile && selectedFile.name.endsWith('.zip')) {
      setFile(selectedFile)
      setUploadResult(null)
    } else {
      alert('Please select a ZIP file')
    }
  }

  const handleUpload = async () => {
    if (!file || !formData.themeName || !formData.themeVersion || !formData.developerName || !formData.description) {
      alert('Please fill all fields and select a file')
      return
    }

    setUploading(true)
    setUploadResult(null)

    try {
      const submitData = new FormData()
      submitData.append('themeFile', file)
      submitData.append('themeName', formData.themeName)
      submitData.append('themeVersion', formData.themeVersion)
      submitData.append('developerName', formData.developerName)
      submitData.append('description', formData.description)

      const response = await fetch('/api/upload-theme', {
        method: 'POST',
        body: submitData
      })

      const result = await response.json()

      if (result.success) {
        setUploadResult('✅ Theme uploaded successfully!')
        setFormData({ themeName: '', themeVersion: '', developerName: '', description: '' })
        setFile(null)
        fetchThemes()
      } else {
        setUploadResult(`❌ Upload failed: ${result.error}`)
      }
    } catch (error) {
      setUploadResult('❌ Network error. Please try again.')
    } finally {
      setUploading(false)
    }
  }

  const downloadPreset = async () => {
    setDownloadingPreset(true)
    try {
      const response = await fetch('/api/download-preset')
      const blob = await response.blob()
      
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = 'theme-preset.zip'
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (error) {
      alert('Download failed')
    } finally {
      setDownloadingPreset(false)
    }
  }

  const downloadTheme = async (themeId: string, filename: string) => {
    try {
      const response = await fetch(`/api/download-theme/${themeId}`)
      const blob = await response.blob()
      
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = filename
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    } catch (error) {
      alert('Download failed')
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <h1 className="text-3xl font-bold text-gray-900">Simple Theme Manager</h1>
          <p className="mt-1 text-sm text-gray-500">Upload and manage themes locally</p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          
          {/* Upload Section */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold text-gray-900">Upload Theme</h2>
              <button
                onClick={downloadPreset}
                disabled={downloadingPreset}
                className="inline-flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                {downloadingPreset ? (
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                ) : (
                  <Download className="w-4 h-4 mr-2" />
                )}
                Download Preset
              </button>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Theme Name
                </label>
                <input
                  type="text"
                  name="themeName"
                  value={formData.themeName}
                  onChange={handleInputChange}
                  placeholder="e.g., Modern Store Theme"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Version
                </label>
                <input
                  type="text"
                  name="themeVersion"
                  value={formData.themeVersion}
                  onChange={handleInputChange}
                  placeholder="e.g., 1.0.0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Developer Name
                </label>
                <input
                  type="text"
                  name="developerName"
                  value={formData.developerName}
                  onChange={handleInputChange}
                  placeholder="Your name or company"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Description
                </label>
                <textarea
                  name="description"
                  value={formData.description}
                  onChange={handleInputChange}
                  rows={3}
                  placeholder="Describe your theme..."
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Theme File (ZIP)
                </label>
                <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                  {file ? (
                    <div>
                      <Package className="w-8 h-8 mx-auto text-green-600 mb-2" />
                      <p className="text-sm font-medium text-green-600">{file.name}</p>
                      <p className="text-xs text-gray-500">
                        {(file.size / (1024 * 1024)).toFixed(2)} MB
                      </p>
                      <button
                        onClick={() => setFile(null)}
                        className="mt-2 text-sm text-red-600 hover:text-red-800"
                      >
                        Remove
                      </button>
                    </div>
                  ) : (
                    <div>
                      <Upload className="w-8 h-8 mx-auto text-gray-400 mb-2" />
                      <p className="text-sm text-gray-600">Choose ZIP file</p>
                      <input
                        type="file"
                        accept=".zip"
                        onChange={(e) => e.target.files && handleFileSelect(e.target.files[0])}
                        className="absolute inset-0 w-full h-full opacity-0 cursor-pointer"
                      />
                    </div>
                  )}
                </div>
              </div>

              {uploadResult && (
                <div className={`p-3 rounded-lg ${
                  uploadResult.includes('✅') 
                    ? 'bg-green-50 text-green-800' 
                    : 'bg-red-50 text-red-800'
                }`}>
                  {uploadResult}
                </div>
              )}

              <button
                onClick={handleUpload}
                disabled={uploading}
                className="w-full py-3 px-4 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 font-medium"
              >
                {uploading ? (
                  <div className="flex items-center justify-center">
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    Uploading...
                  </div>
                ) : (
                  'Upload Theme'
                )}
              </button>
            </div>
          </div>

          {/* Themes List */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-900 mb-6">
              Uploaded Themes ({themes.length})
            </h2>

            {loading ? (
              <div className="text-center py-8">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
                <p className="mt-2 text-gray-500">Loading themes...</p>
              </div>
            ) : themes.length === 0 ? (
              <div className="text-center py-8">
                <Package className="w-12 h-12 mx-auto text-gray-400 mb-4" />
                <p className="text-gray-500">No themes uploaded yet</p>
              </div>
            ) : (
              <div className="space-y-4">
                {themes.map((theme) => (
                  <div key={theme.id} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <h3 className="font-semibold text-gray-900">{theme.name}</h3>
                        <p className="text-sm text-gray-600 mt-1">{theme.description}</p>
                        <div className="flex items-center space-x-4 mt-2 text-xs text-gray-500">
                          <div className="flex items-center">
                            <User className="w-3 h-3 mr-1" />
                            {theme.developer}
                          </div>
                          <div className="flex items-center">
                            <Package className="w-3 h-3 mr-1" />
                            v{theme.version}
                          </div>
                          <div className="flex items-center">
                            <Calendar className="w-3 h-3 mr-1" />
                            {new Date(theme.uploadDate).toLocaleDateString()}
                          </div>
                        </div>
                      </div>
                      <button
                        onClick={() => downloadTheme(theme.id, theme.filename)}
                        className="ml-4 inline-flex items-center px-3 py-1 bg-green-600 text-white text-sm rounded hover:bg-green-700"
                      >
                        <Download className="w-3 h-3 mr-1" />
                        Download
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
EOF

echo ""
echo "🎨 Step 8: Updating layout and styles..."
cat > src/app/layout.tsx << 'EOF'
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Simple Theme Manager',
  description: 'Upload and manage themes locally',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
EOF

cat > src/app/globals.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  background-color: #f9fafb;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}
EOF

echo ""
echo "⚙️ Step 9: Updating Next.js configuration..."
cat > next.config.js << 'EOF'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    serverComponentsExternalPackages: ['adm-zip']
  },
  api: {
    bodyParser: {
      sizeLimit: '50mb',
    },
  },
}

module.exports = nextConfig
EOF

echo ""
echo "🧪 Step 10: Testing setup..."
# Create initial themes.json if it doesn't exist
echo "[]" > themes/themes.json

# Test if all files were created
missing_files=()
required_files=(
  "src/types/index.ts"
  "src/lib/file-storage.ts"
  "src/lib/theme-presets.ts"
  "src/app/page.tsx"
  "src/app/layout.tsx"
  "src/app/globals.css"
  "themes/themes.json"
)

for file in "${required_files[@]}"; do
  if [ ! -f "$file" ]; then
    missing_files+=("$file")
  fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
  echo "✅ All files created successfully!"
else
  echo "⚠️  Some files are missing:"
  printf '%s\n' "${missing_files[@]}"
fi

echo ""
echo "🎉 SIMPLE THEME MANAGER SETUP COMPLETE!"
echo "======================================"
echo ""
echo "📁 What was created:"
echo "   • Local file storage (no database needed!)"
echo "   • Theme upload and management"
echo "   • Theme preset generator"
echo "   • Simple admin interface"
echo ""
echo "🚀 Ready to use:"
echo "   npm run dev              # Start the application"
echo "   http://localhost:3000    # Access your theme manager"
echo ""
echo "✨ Features:"
echo "   📤 Upload themes (ZIP files)"
echo "   📥 Download theme preset"
echo "   📋 View uploaded themes list"
echo "   💾 Local storage only (themes/ folder)"
echo ""
echo "📂 Files are stored in:"
echo "   • themes/themes.json     # Theme metadata"
echo "   • themes/theme_*.zip     # Uploaded theme files"
echo ""
echo "🎨 Happy theme managing! ✨"