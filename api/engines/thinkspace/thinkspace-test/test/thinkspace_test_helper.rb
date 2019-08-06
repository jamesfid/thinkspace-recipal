require 'test_helper'
require 'pp'

PaperTrail.enabled = false

def seed_test_data(options={}); ::Totem::Test::Seed.load(options); end

def generate_model_serializers; ::Thinkspace::Common::User; end # can do before running the tests to prevent serializer override messages inter-mixed with test output
