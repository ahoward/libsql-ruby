require_relative '../lib/libsql'

db = Libsql::Database.new(path: 'local.db')

db.connect do |conn|
  conn.execute_batch <<-SQL
    DROP TABLE IF EXISTS movies;
    CREATE TABLE IF NOT EXISTS movies (title TEXT, year INT, embedding F32_BLOB(3));
    CREATE INDEX movies_idx ON movies (libsql_vector_idx(embedding));

    INSERT INTO movies (title, year, embedding)
    VALUES
      ('Napoleon', 2023, vector32('[1,2,3]')),
      ('Black Hawk Down', 2001, vector32('[10,11,12]')),
      ('Gladiator', 2000, vector32('[7,8,9]')),
      ('Blade Runner', 1982, vector32('[4,5,6]'));
  SQL

  rows = conn.query "SELECT title, year FROM vector_top_k('movies_idx', '[4,5,6]', 3) JOIN movies ON movies.rowid = id"

  print "Movies: #{rows.to_a}\n"

  rows.close
end
