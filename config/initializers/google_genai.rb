# frozen_string_literal: true

# Load the google-genai gem manually since it conflicts with Zeitwerk's
# naming conventions (gem defines Google::Genai but Zeitwerk expects GenAI).
# We bypass Zeitwerk by loading from the gem's absolute path.
gem_spec = Gem.loaded_specs["google-genai"]
if gem_spec
  load gem_spec.full_gem_path + "/lib/google/genai.rb"
end
