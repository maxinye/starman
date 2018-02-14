class History
  def self.db_path
    "#{Settings.rc_root}/history.db"
  end

  def self.db_cmd
    'sqlite3'
  end

  def self.init
    # Create history database if not exists.
    if not File.file? db_path
      CLI.notice "Initialize history database at #{CLI.blue db_path}."
      FileUtils.mkdir_p File.dirname(db_path)
      system "cat #{ENV['STARMAN_ROOT']}/framework/db/tables.sql | #{db_cmd} #{db_path}"
    end
  end

  def self.save_install package
    system "echo 'insert into install (name, version, prefix, time) " +
    "values (\"#{package.name}\", \"#{package.version}\", \"#{package.prefix}\", \"#{Time.now.to_s}\")' | #{db_cmd} #{db_path}"
  end

  def self.installed? package
    res = `echo 'select * from install where name = \"#{package.name}\"' | #{db_cmd} #{db_path}`.split('|')
    package.name == res[1] and package.version == res[2] and package.prefix == res[3]
  end
end
