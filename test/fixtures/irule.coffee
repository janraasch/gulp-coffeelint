iruleRegex = /gulp is awesome/
module.exports = class IRule
    rule:
        name: 'awesome_custom_rule'
        level: 'error'
        message: 'Hold your horses there, pally!'
        description: """
            Sure gulp is good, but there are other ways too :)
            """

    lintLine: (line, lineApi) ->
        iruleRegex.test(line)
