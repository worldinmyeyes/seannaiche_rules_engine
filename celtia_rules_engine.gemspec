# -*- encoding: utf-8 -*-
# stub: celtia_rules_engine 0.1.37 ruby lib

Gem::Specification.new do |s|
  s.name = "celtia_rules_engine"
  s.version = "0.1.37"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Graham McKay (team celtia)"]
  s.date = "2014-04-09"
  s.email = "g.mckay.08@aberdeen.ac.uk"
  s.executables = ["celtia_rules_engine", "web_runner"]
  s.files = ["Gemfile", "Gemfile.lock", "Procfile", "bin/celtia_rules_engine", "bin/web_runner", "lib/board.rb", "lib/celtia_rules_engine.rb", "lib/game.rb", "lib/move.rb", "lib/piece.rb", "lib/player.rb", "lib/position.rb", "lib/square.rb", "lib/string.rb", "spec/board_spec.rb", "spec/spec_helper.rb", "test/log.txt", "test/output.txt", "test/test_games/2player_spellcasting", "test/test_games/2seandown.txt", "test/test_games/bolt_revive_test", "test/test_games/capture_across_cauldron", "test/test_games/cauldron_spell", "test/test_games/flight_capture_bansidh", "test/test_games/flight_test", "test/test_games/freeze_test_block", "test/test_games/freeze_test_deactivate", "test/test_games/king_diagonal_move_from_temple", "test/test_games/merc_pawn_to_cauldron", "test/test_games/merc_test", "test/test_games/mist_test", "test/test_games/possess_protect", "test/test_games/promote_test4", "test/test_games/sean-climb.txt", "test/test_games/seannaiche_enter_cauldron_test", "test/test_games/shapeshift_clear", "test/test_games/shapeshift_test", "test/test_games/shapeshift_test2", "test/test_games/shapeshift_test_capture", "test/test_games/shield", "test/test_games/shield2", "test/test_games/spell-bolt.txt", "test/test_games/spell-flight.txt", "test/test_games/spell-mist.txt", "test/test_games/spell-possess.txt", "test/test_games/spell-promote.txt", "test/test_games/spell_freeze.txt", "test/test_games/spell_immunity", "test/test_games/win_by_capture", "test/test_games/win_by_cauldron", "test/unused_test_games/1_mist.txt", "test/unused_test_games/extra_bansidh", "test/unused_test_games/mist_test2", "test/unused_test_games/possess_test", "test/unused_test_games/promote_test3", "test/unused_test_games/temple", "test/unused_test_games/test2", "test/unused_test_games/test_game", "test/unused_test_games/test_game2", "test/unused_test_games/test_game3"]
  s.rubygems_version = "2.2.1"
  s.summary = "Rules engine for Celtia."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 0"])
  end
end
