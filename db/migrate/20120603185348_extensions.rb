class Extensions < ActiveRecord::Migration
  def up
    # for heroku :)
    execute "create extension fuzzystrmatch"
    execute "create extension pg_trgm"
  end

  def down
  end
end
