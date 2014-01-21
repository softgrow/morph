class Database
  attr_reader :scraper
  delegate :data_path, to: :scraper

  def initialize(scraper)
    @scraper = scraper
  end

  def self.sqlite_db_filename
    "data.sqlite"
  end

  def self.sqlite_table_name
    "data"
  end

  def sqlite_db_path
    File.join(data_path, Database.sqlite_db_filename)
  end

  def sql_query(query, readonly = true)
    db = SQLite3::Database.new(sqlite_db_path, results_as_hash: true, type_translation: true, readonly: readonly)
    # If database is busy wait 5s
    db.busy_timeout(5000)
    db.execute(query)
  end

  def sql_query_safe(query, readonly = true)
    begin
      sql_query(query, readonly)
    rescue SQLite3::CantOpenException, SQLite3::SQLException
      nil
    end
  end

  def no_rows
    sql_query_safe("select count(*) from #{Database.sqlite_table_name}").first.values.first
  end

  def sqlite_db_size
    if File.exists?(sqlite_db_path)
      File::Stat.new(sqlite_db_path).size
    else
      0
    end
  end
end