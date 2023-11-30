class ResetCollationForTags < ActiveRecord::Migration[6.0]
  def up
    return unless ActsAsTaggableOn::Utils.using_mysql?

    # Get the default character set
    default_charset = ActiveRecord::Base.connection.execute('SELECT @@character_set_database').first[0]

    # Get the default collation
    default_collation = ActiveRecord::Base.connection.execute('SELECT @@collation_database').first[0]

    execute(
      "ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET #{default_charset} COLLATE #{default_collation};"
    )

    execute(
      'ALTER TABLE tags MODIFY name varchar(255) DEFAULT NULL;'
    )
  end

  def down
    return unless ActsAsTaggableOn::Utils.using_mysql?

    execute(
      'ALTER TABLE tags MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_bin;'
    )
  end
end
