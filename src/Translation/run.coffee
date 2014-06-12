angular.module('translation').
run( (gettextCatalog, Local, $rootScope)->

  $rootScope.$on('$ChangeLanguage', ($event, language)->
    Local.get(language).then(
      (data) -> #Success
        gettextCatalog.setStrings(language, data.data)
        gettextCatalog.currentLanguage = language
        $rootScope.$broadcast('$translateChangeSuccess', language)
      ,(err) -> #Error
        if language != 'en'
          $rootScope.$broadcast('$translateChangeError', language)
    )
  )
)
