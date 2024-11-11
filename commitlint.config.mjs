export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['fix', 'feat', 'chore', 'build', 'ci', 'test'],
    ],
  },
  ignores: [
    (message) => message.startsWith('build(deps): bump ')
  ]
};
