local BUILD_IMAGE_TAG = 'build';
local DEBIAN_VERSION = 'bookworm';
local IMAGE = 'rspamd/rbldnsd';

local docker_pipeline = {
  kind: 'pipeline',
  type: 'docker',
};

local platform(arch) = {
  platform: {
    os: 'linux',
    arch: arch,
  },
};

local ci_pipeline(arch) = {
  name: 'default-' + arch,
  steps: [
    {
      name: 'test',
      image: std.format('%s:%s', [IMAGE, BUILD_IMAGE_TAG]),
      commands: [
        'mkdir ../build.rbldnsd',
        'cd ../build.rbldnsd',
        'cmake -DNO_IPv6=ON $DRONE_WORKSPACE',
        'make',
        'cd $DRONE_WORKSPACE',
        'mv ../build.rbldnsd/rbldnsd* .',
        'bash -c "source /venv/bin/activate && robot test/functional/cases"',
        'bash -c "source /venv/bin/activate && python3 test/pyunit/tests.py"',
      ],
    },
  ],
  trigger: {
    event: {
      include: [
        'push',
        'pull_request',
      ],
    },
  },
} + docker_pipeline + platform(arch);

local docker_defaults = {
  username: {
    from_secret: 'docker_username',
  },
  password: {
    from_secret: 'docker_password',
  },
};

local trigger_on_tag = {
  trigger: {
    event: {
      include: [
        'tag',
      ],
    },
  },
};

local dockerbuild_pipeline(arch) = {
  name: 'docker-' + arch,
  image: 'plugins/docker',
  settings: {
    dockerfile: 'Dockerfile',
    dry_run: true,
    build_args: [
      'TARGETARCH=' + arch,
    ],
    tags: [
      'latest-' + arch,
    ],
  } + docker_defaults,
} + docker_pipeline + platform(arch) + trigger_on_tag;

/*
local multiarch_docker_pipeline = {
}
*/

local signature_placeholder = {
  hmac: '0000000000000000000000000000000000000000000000000000000000000000',
  kind: 'signature',
};

[
  ci_pipeline('amd64'),
  ci_pipeline('arm64'),
  dockerbuild_pipeline('amd64'),
  dockerbuild_pipeline('arm64'),
  //multiarch_docker_pipeline,
  signature_placeholder,
]
