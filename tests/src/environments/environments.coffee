utils   = require '../utils/utils.js'
helpers = require '../helpers/helpers.js'
faker   = require 'faker'
assert  = require 'assert'

modalSelector = '.activity-modal.vm-settings'


openVmSettingsModal = (browser) ->

    vmSelector = '.activity-sidebar a.running'

    browser
      .waitForElementVisible   vmSelector, 20000
      .pause                   5000
      .moveToElement           vmSelector + ' span', 125, 20
      .click                   vmSelector + ' span'
      .waitForElementVisible   modalSelector, 20000 # Assertion


clickMoreButtonInVMSettingsModal = (browser) ->

    browser
      .waitForElementVisible  '.settings form.with-fields .moreview', 20000
      .click                  '.settings form.with-fields .moreview label.more'
      .pause  200


seeUpgradeModal = (browser) ->

    sidebarTitle = '[testpath=main-sidebar] .activity-sidebar .vms .sidebar-title'

    browser
      .waitForElementVisible   '[testpath=main-sidebar]', 20000
      .waitForElementVisible   sidebarTitle, 20000
      .moveToElement           sidebarTitle + ' a.buy-vm', 10, 10
      .click                   sidebarTitle + ' a.buy-vm'
      .waitForElementVisible   '.computeplan-modal.free-plan .kdmodal-inner', 20000 # Assertion


  addDomain = (browser) ->

    user = helpers.beginTest(browser)
    helpers.waitForVMRunning(browser)

    domainSelector    = '.more-form .domains .domains-a-hrefhttplearnkodingcomfaqvm-hostname-target-blank-span-classdomain-helpspan-a-span-classdomain-togglespan span.domain-toggle'
    paragraph         = helpers.getFakeText()
    createDomainName  = paragraph.split(' ')[0]
    domainName        = createDomainName + '.' + user.username + '.dev.koding.io'

    openVmSettingsModal(browser)

    clickMoreButtonInVMSettingsModal(browser)

    browser
      .waitForElementVisible    '.more-form .domains', 20000
      .waitForElementVisible    domainSelector, 20000
      .click                    domainSelector
      .waitForElementVisible    '.domains-view input.text', 20000
      .setValue                 '.domains-view input.text', createDomainName + '\n'
      .waitForElementVisible    '.domains-view .in-progress.kdloader', 10000
      .waitForElementNotVisible '.domains-view .in-progress.kdloader', 20000
      .assert.containsText      '.domains-view .listview-wrapper', domainName

    return domainName


module.exports =


  openVmDomain: (browser) ->

    linkSelector = modalSelector + ' .assigned-url .custom-link-view'

    helpers.beginTest(browser)
    helpers.waitForVMRunning(browser)

    openVmSettingsModal(browser)

    browser
      .waitForElementVisible   linkSelector, 20000
      .getAttribute            linkSelector, 'href', (result) ->
        domain = result.value

        browser
          .url domain
          .waitForElementVisible  '#container', 20000
          .waitForElementVisible  '#container .hellobox', 20000
          .end()


  turnOffVm: (browser) ->

    linkSelector = modalSelector + ' .statustoggle .input-wrapper'

    helpers.beginTest(browser)
    helpers.waitForVMRunning(browser)

    openVmSettingsModal(browser)

    browser
      .waitForElementVisible   linkSelector, 20000
      .waitForElementVisible   linkSelector + ' .koding-on-off a.knob', 20000
      .click                   linkSelector + ' .koding-on-off a.knob'
      .waitForElementVisible   '.env-machine-state .kdmodal-content .state-label.stopping', 20000
      .waitForElementVisible   '.env-machine-state .kdmodal-content .state-label.stopped', 300000
      .waitForElementVisible   '.env-machine-state .kdmodal-content .turn-on.state-button', 20000 # Assertion
      .end()


  turnOnVm: (browser)->

    helpers.beginTest(browser)
    helpers.waitForVMRunning(browser)
    browser.end()


  seeUpgradeModal: (browser) ->

    helpers.beginTest(browser)
    helpers.waitForVMRunning(browser)
    seeUpgradeModal(browser)
    browser.end()
  makeAlwaysOnForNotPaidUser: (browser) ->

    buttonSelector = '.more-form .alwayson'

    helpers.beginTest(browser)
    helpers.waitForVMRunning(browser)

    openVmSettingsModal(browser)

    clickMoreButtonInVMSettingsModal(browser)

    browser
      .waitForElementVisible  buttonSelector, 20000
      .click                  buttonSelector + ' .input-wrapper .koding-on-off a.knob'
      .waitForElementVisible  '.kdmodal-content a.custom-link-view', 20000 # Assertion
      .end()


  addDomain: (browser) ->

    addDomain(browser)
    browser.end()


  deleteDomain: (browser) ->

    domainName = addDomain(browser)

    domainItem = '.domains-view .kdlistitemview-domain:last-child'
    loader     = '.domains-view .in-progress.kdloader'

    browser
      .moveToElement             domainItem, 10, 10
      .click                     domainItem + ' span.remove-domain'
      .waitForElementVisible     loader, 10000
      .waitForElementNotVisible  loader, 20000
      .getText                   domainItem, (result) =>
        assert.notEqual          result.value, domainName # Assertion

        browser.end()
