FileUtils.remove_dir Rails.root.join('public/doc'), force = true
FileUtils.copy_entry Rails.root.join('doc'), Rails.root.join('public/doc')
FileUtils.copy_entry Rails.root.join('erd.pdf'), Rails.root.join('public/doc/erd.pdf')