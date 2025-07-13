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
