kd = require 'kd'
HomeWelcome = require './'
LocalStorage = require 'app/localstorage'
globals = require 'globals'
_ = require 'lodash'

module.exports = class WelcomeModal extends kd.ModalView

  constructor: (options = {}, data) ->

    storage = new LocalStorage 'Koding', '1.0'
    landedOnWelcome = storage.getValue 'landedOnWelcome'

    options.cssClass = "HomeWelcomeModal#{if landedOnWelcome then ' hidden' else ''}"
    options.width    = 710
    options.overlay  = yes
    options.overlayOptions = { cssClass: if landedOnWelcome then 'hidden' else '' }

    super options, data

    { router, mainController } = kd.singletons

    router.once 'RouteInfoHandled', => @destroy no

    mainController.once 'AllWelcomeStepsDone', @bound 'destroy'
    mainController.once 'AllWelcomeStepsDone', @bound 'showCongratulationModal'
    mainController.once 'AllWelcomeStepsNotDoneYet', @bound 'initialShow'

    storage.setValue 'landedOnWelcome', ''


  showCongratulationModal: ->

    { appStorageController } = kd.singletons

    appStorage = appStorageController.storage "WelcomeSteps-#{globals.currentGroup.slug}"
    appStorage.fetchValue 'OnboardingSuccessModalShown', (result) ->

      return  if result

      appStorage.setValue 'OnboardingSuccessModalShown', yes

      modal = new kd.ModalView
        title : 'Success!'
        width : 530
        cssClass : 'Congratulation-modal'
        content : "<p class='description'>Congratulations. You have completed all items on your onboarding list.</p>"


      kd.View::addSubView.call modal, new kd.CustomHTMLView
        cssClass : 'alien'


      modal.addSubView new kd.CustomHTMLView
        cssClass : 'image-wrapper'

      modal.addSubView new kd.ButtonView
        title : 'KEEP ROCKING!'
        cssClass: 'GenericButton'
        callback : -> modal.destroy()


  initialShow: ->
    @show()
    @_windowDidResize()
    { width } = @getOptions()
    height = @getHeight()
    leftOrigin = "#{-((window.innerWidth - width) / 2 - 240)}px"
    topOrigin  = "#{-((window.innerHeight - height) / 2 - 22)}px"
    @getElement().style.transformOrigin = "#{leftOrigin} #{topOrigin}"


  viewAppended: ->

    super

    @addSubView new HomeWelcome


  destroy: (selfInitiated = yes) ->

    @setClass 'out'

    { router } = kd.singletons
    { visitedRoutes: tempVisitedRoutes } = router
    # In case of visitedRoutes comes like this
    # `Any route` -> `/Welcome` -> `/Home` -> `/Welcome` ->
    # `/Home` -> `/Welcome` -> `/Home` -> `/Welcome`
    # to findout correct back route and prevent infinite loop
    # between `/Welcome` and `/Home` routes, we need to remove
    # those unnecessary paths to access `/Any Route`
    # FIXME: ~HK
    tempVisitedRoutes =  _.flatten _.uniqWith _.chunk(tempVisitedRoutes, 2), _.isEqual
    [..., beforeLast, last] = tempVisitedRoutes

    tempVisitedRoutes.pop()  if last is '/Welcome' and beforeLast.indexOf('/Home') > -1

    welcomeIndex = tempVisitedRoutes.lastIndexOf('/Welcome')
    router.handleRoute tempVisitedRoutes[welcomeIndex - 1]  if selfInitiated

    # fat arrow is not unnecessary - sy
    kd.utils.wait 400, => super

