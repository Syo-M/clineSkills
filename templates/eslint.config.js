// Starter ESLint flat config — copy to the target repo's eslint.config.js.
// ローカルLLMはルールを「知っていても」破ります。破った瞬間に赤くするのがこのファイルの仕事です。
// Install: npm i -D eslint @eslint/js typescript-eslint eslint-plugin-import eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-jsx-a11y
// This is a STARTING POINT — adapt `files`/`ignores` and framework presets to the project.
import js from '@eslint/js';
import tseslint from 'typescript-eslint';
import importPlugin from 'eslint-plugin-import';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import jsxA11y from 'eslint-plugin-jsx-a11y';

export default tseslint.config(
  { ignores: ['dist/**', 'build/**', '.next/**', 'storybook-static/**'] },
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        // allowDefaultProject: root config files (this file included) are not in tsconfig —
        // without this, `eslint .` fails on its own config with "not found by the project service".
        projectService: { allowDefaultProject: ['*.js', '*.mjs', '*.cjs', '*.config.ts'] },
      },
    },
    settings: { react: { version: 'detect' } },
    plugins: { import: importPlugin, react, 'react-hooks': reactHooks, 'jsx-a11y': jsxA11y },
    rules: {
      // 01-core: no any, no ts-ignore
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/ban-ts-comment': ['error', { 'ts-expect-error': 'allow-with-description', 'ts-ignore': true }],

      // react-components skill
      ...reactHooks.configs.recommended.rules, // rules-of-hooks
      // recommended leaves exhaustive-deps at 'warn'; ESLint exits 0 on warnings, so the
      // /pre-ship lint gate would pass with missing deps — force it to error.
      'react-hooks/exhaustive-deps': 'error',
      'react/no-array-index-key': 'error',
      'import/no-default-export': 'error',

      // security skill: no eval family, no unsanitized HTML, no inline styles
      'no-eval': 'error',
      'no-implied-eval': 'error',
      'no-new-func': 'error',
      'react/no-danger': 'error',
      'react/forbid-dom-props': ['error', { forbid: ['style'] }],

      // a11y skill (recommended set as errors)
      ...jsxA11y.configs.recommended.rules,
    },
  },
  // Plain JS files (configs, scripts) are not type-checked — prevents project-service errors
  {
    files: ['**/*.js', '**/*.mjs', '**/*.cjs'],
    extends: [tseslint.configs.disableTypeChecked],
  },
  // Default-export exceptions (framework routes, configs, CSF meta)
  {
    files: [
      '**/app/**', '**/pages/**', 'src/pages/**',
      '**/*.stories.*', '**/*.config.*', '.storybook/**',
    ],
    rules: { 'import/no-default-export': 'off' },
  },
  // Tests: relax type-aware strictness where it fights test ergonomics
  {
    files: ['**/*.test.*', '**/*.spec.*'],
    rules: { '@typescript-eslint/no-unsafe-assignment': 'off' },
  },
);
