require 'spec_helper'
describe 'fluentd' do

    context "when the class is simply included" do

      # let(:params) {{ 
      #     :ensure => 'present',
      #     :package_name       => 'fluentd',
      #     :package_provider   => 'gem'
      #   }}

        it { should contain_class('fluentd::package') }
        it { should contain_class('fluentd::service') }

        it "should declare a package from the default configuration" do
          should contain_package('fluentd')
            .with_provider('gem')
        end

    end

    context "when the package attributes are used" do
      let(:params) {{
          :package_name       => 'rubygems-fluentd',
          :package_provider   => 'apt'
        }}

        it "should declare a package from the given configuration" do
          should contain_package('rubygems-fluentd')
            .with_provider('apt')
        end

    end

end