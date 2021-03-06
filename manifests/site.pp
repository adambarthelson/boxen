require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::home}/homebrew/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  #include hub

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # default ruby versions
  #include ruby::1_8_7
  #include ruby::1_9_2
  #include ruby::1_9_3
  #include ruby::2_0_0

  # common, useful packages
  package {
    [
      'ack',
      'coreutils',
      'findutils',
      'gawk',
      'gnutls',
      'gnu-getopt',
      'gnu-indent',
      'gnu-sed',
      'gnu-tar',
      'icu4c',
      'nodejs',
      'pyenv',
      'task',
      'the_silver_searcher',
      'tmux',
      'youtube-dl'
    ]:
  }

  # my own stuff
  include chrome
  include emacs
  include dropbox
  include irssi
  include github_for_mac
  include gh
  include heroku
  include iterm2::stable
  include macvim
  include moreutils
  include screen
  include skydrive
  include skype
  include sourcetree
  include spotify
  include sublime_text_2
  include textmate::textmate2::release
  include tunnelblick::beta
  include vagrant
  include vim
  include virtualbox
  include vlc
  include wget
  include xz
  
  # osx config options
  include osx::global::enable_keyboard_control_access
  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog
  include osx::dock::autohide
  include osx::finder::unhide_library
  include osx::universal_access::ctrl_mod_zoom 
  include osx::no_network_dsstores
  include osx::software_update

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
