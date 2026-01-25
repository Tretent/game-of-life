# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  # Skip CSP in development to allow Letter Opener Web (uses iframes and inline styles)
  if !Rails.env.development? || !Rails.env.test?
    config.content_security_policy do |policy|
      policy.default_src :self # same origin
      policy.font_src    :self, :data # url
      policy.img_src     :self, :data
      policy.object_src  :none
      policy.script_src  :self
      policy.style_src   :self
      policy.connect_src :self
      policy.frame_ancestors :none
    end

    # Generate nonces for permitted importmap, inline scripts, and inline styles.
    config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
    config.content_security_policy_nonce_directives = %w[script-src style-src]
  end
end
