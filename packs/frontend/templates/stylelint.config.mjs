// Starter Stylelint config — copy to the target repo's stylelint.config.mjs.
// css-styling スキルのトークン規則を機械的に強制します: themableなプロパティはvar()必須、生のz-index禁止、
// 未定義トークンの参照禁止。
// Install: npm i -D stylelint stylelint-config-standard stylelint-declaration-strict-value stylelint-value-no-unknown-custom-properties
/** @type {import('stylelint').Config} */
export default {
  extends: ['stylelint-config-standard'],
  plugins: ['stylelint-declaration-strict-value', 'stylelint-value-no-unknown-custom-properties'],
  rules: {
    // 未定義のCSSカスタムプロパティ参照を検出。実機evalでローカルLLMが var(--存在しないトークン) を
    // 2度発明した(色が変わらない実バグ)への機械的対策。トークン定義の場所が違う場合はパスを直す。
    'csstools/value-no-unknown-custom-properties': [true, { importFrom: ['src/styles/tokens.css'] }],
    // Require var() for themable properties — no raw hex/px in component modules.
    'scale-unlimited/declaration-strict-value': [
      [
        '/color/', 'fill', 'stroke', 'z-index', 'box-shadow', 'transition-duration',
        '/^margin/', '/^padding/', 'gap', 'row-gap', 'column-gap',
      ],
      {
        ignoreValues: [
          'transparent', 'currentColor', 'inherit', 'none', 'initial', 'unset',
          '/^(0|auto)( (0|auto)){0,3}$/',
        ],
      },
    ],
    // Ban arbitrary z-index integers (use the token ladder)
    'declaration-property-value-disallowed-list': {
      'z-index': ['/^\\d+$/'],
    },
    // CSS Modules use camelCase class names (styles.primaryButton)
    'selector-class-pattern': ['^[a-z][a-zA-Z0-9]+$', { resolveNestedSelectors: true }],
  },
  // tokens.css defines the primitives — exempt it from the var()-only rule
  overrides: [
    { files: ['**/tokens.css'], rules: { 'scale-unlimited/declaration-strict-value': null } },
  ],
};
