require "language_pack/shell_helpers"
module LanguagePack::Installers; end

module LanguagePack::Installers::RubyInstaller
  include LanguagePack::ShellHelpers

  DEFAULT_BIN_DIR = "bin"

  def self.installer(ruby_version)
    if ruby_version.rbx?
      LanguagePack::Installers::RbxInstaller
    else
      LanguagePack::Installers::HerokuRubyInstaller
    end
  end

  def install(ruby_version, install_dir)
    fetch_unpack(ruby_version, install_dir)
    upgrade_rubygems(install_dir)
    setup_binstubs(install_dir)
  end

  def upgrade_rubygems(install_dir)
    topic 'Using Rubygems version ' +
          run_stdout("#{install_dir}/bin/gem --version")

    up_to_date = run_stdout(
      "#{install_dir}/bin/ruby -e 'puts Gem.respond_to?(:activate_bin_path)'"
    ).strip
    return if up_to_date == 'true'

    topic 'Upgrading Rubygems...'
    run("#{install_dir}/bin/gem update --system")
    topic 'Using Rubygems version ' +
          run_stdout("#{install_dir}/bin/gem --version")
  end

  def setup_binstubs(install_dir)
    FileUtils.mkdir_p DEFAULT_BIN_DIR
    run("ln -s ruby #{install_dir}/bin/ruby.exe")

    Dir["#{install_dir}/bin/*"].each do |vendor_bin|
      run("ln -s ../#{vendor_bin} #{DEFAULT_BIN_DIR}")
    end
  end
end
