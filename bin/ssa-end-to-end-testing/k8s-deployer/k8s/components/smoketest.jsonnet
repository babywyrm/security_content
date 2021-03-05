
local params = import '../params.libsonnet';

local job = {
    apiVersion: 'batch/v1',
    kind: 'Job',
    metadata: {
      generateName: 'ssa-smoketest-',
        labels: {
            name: 'ssa-smoketest',
        	uploaderLabel: std.extVar('CI_COMMIT_SHORT_SHA'),
        },
    },
    spec: {
        activeDeadlineSeconds: 600,
        ttlSecondsAfterFinished: 100,
        template: {
            metadata: {
                annotations: {
                    'splunk8s.io.vault/init-container': 'true',
                },
            },
            spec: {
              serviceAccountName: params.components.serviceAccountName,
              restartPolicy: 'Never',
              containers: [
                {
                  name: 'ssa-smoke-test',
                  image: params.components.smokeTestImage,
                  imagePullPolicy: 'Always',
                  env: [
                    {
                        "name": 'SRCBRANCH',
                        "value": std.extVar('SRCBRANCH')
                    },
                    {
                        "name": 'SMOKETEST_VAULT_READ_PATH',
                        "value": params.components.vaultReadPath
                    },
                    {
                        "name": 'DSP_ENV',
                        "value": params.components.dspEnv
                    },
                    {
                        "name": 'TENANT',
                        "value": params.components.tenant
                    },
                    {
                        "name": 'ENV',
                        "value": std.extVar('qbec.io/env')
                    },
                  ],
                  resources: {
                    limits: {
                        cpu: '1',
                        memory: '1000Mi'
                    },
                    requests: {
                        cpu: '800m',
                        memory: '750Mi'
                    },
                  },
                  command: ['/bin/bash', '-c'],
                  args: ['cd /smoketest && ./entrypoint.sh'],
                },
              ],
            },
        },
    },
  };

job
