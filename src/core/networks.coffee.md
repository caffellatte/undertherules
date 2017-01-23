# networs.com
Simple collection of libraries for authorization, data scraping & etc.

## using array for storing reserved keywords for mix-ins.

    moduleKeywords = ['extended', 'included']

## Declare Module that using mix-ins

    class Module

### **Extending**

      @extend: (obj) ->
        for key, value of obj when key not in moduleKeywords
          @[key] = value

        obj.extended?.apply(@)
        this

### **Including**

      @include: (obj) ->
        for key, value of obj when key not in moduleKeywords
          @::[key] = value

        obj.included?.apply(@)
        this

## Defi

    ORM =
      find: (id) ->
        log id
      create: (attrs) ->
      extended: ->
        @include
          save: ->

    class User extends Module
      @extend ORM

## Start

    user = User.find(1)

    # user = new User
    # user.save()
