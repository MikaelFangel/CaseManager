export default {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['fix', 'feat', 'chore', 'build', 'ci', 'test'],
    ],
    'body-max-line-length': [
      0,
      'always',
      250
    ]
  },
  ignores: [
    (message) => message.startsWith('build(deps): bump ')
  ]
};
