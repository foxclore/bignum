class BigUnsigned
    var digits: Array[U8]
    var len: USize

    fun array_from_string(starter: String): Array[U8] =>
        let res = Array[U8](starter.size())
        for element in starter.values() do
            res.push(element - 48)
        end
        res
    
    new create(starter: String = "") =>
        if starter == "" then
            digits= [0]
            len = 1
        else
            len = starter.size()
            digits = Array[U8](len)
            digits = array_from_string(starter)
        end

    new from_I128(starter: I128) =>
        len = starter.string().size()
        digits = Array[U8](len)
        digits = array_from_string(starter.string())

    new from_U128(starter: U128) =>
        len = starter.string().size()
        digits = Array[U8](len)
        digits = array_from_string(starter.string())

    new from_array(starter: Array[U8]) =>
        len = starter.size()
        digits = Array[U8](len)
        for element in starter.values() do
            digits.push(element)
        end

    fun string(): String =>
        var result = ""
        for d in digits.values() do
            result = result + d.string()
        end    
        result

    fun i128(): I128 =>
        var res: I128 = 0
        for element in digits.values() do
            res = (res*10) + element.i128()
        end
        res

    fun eq(other: BigUnsigned): Bool =>
        if other.len != len then
            return false
        end

        try
            var counter: USize = 0
            while counter < len do
                if other.digits.apply(counter)? != digits.apply(counter)? then
                    return false
                end
                counter = counter + 1
            end
        else
            return false
        end

        true

    fun ne(other: BigUnsigned): Bool =>
        not eq(other)

    fun lt(other: BigUnsigned): Bool =>
        if other.len > len then
            return true
        elseif other.len < len then
            return false
        end

        try
            var counter: USize = 0
            while counter < len do
                if other.digits.apply(counter)? < digits.apply(counter)? then
                    return false
                end
                counter = counter + 1
            end
        else
            return false
        end

        true

    fun le(other: BigUnsigned): Bool =>
        let t = BigUnsigned(string())
        (t < other) or (t == other)

    fun gt(other: BigUnsigned): Bool =>
        let t = BigUnsigned(string())
        not ((t < other) or (t == other))
    
    fun ge(other: BigUnsigned): Bool =>
        let t = BigUnsigned(string())
        not (t < other)

    fun copy(): BigUnsigned =>
        BigUnsigned.from_array(digits.clone())

    fun add(other: BigUnsigned): BigUnsigned =>
        try
            var target_digits_1: Array[U8]
            var target_digits_2: Array[U8]
            
            if other <= copy() then
                target_digits_1 = digits.reverse()
                target_digits_2 = other.digits.reverse()
            else
                target_digits_1 = other.digits.reverse()
                target_digits_2 = digits.reverse()
            end
            
            var counter: USize = 0
            let l2 = target_digits_2.size()
            var overflow: Bool = false
            var result = Array[U8](target_digits_1.size())

            for element_1 in target_digits_1.values() do
                var element_2: U8 = 0

                if counter < l2 then
                    element_2 = target_digits_2.apply(counter)?
                end

                var res = element_1 + element_2

                if overflow then
                    res = res + 1
                    overflow = false
                end

                if res >= 10 then
                    res = res - 10
                    overflow = true
                end

                result.push(res)

                counter = counter + 1
            end

            if overflow then
                result.push(1)
            end

            return BigUnsigned.from_array(result.reverse())
        else
            return BigUnsigned.from_array([0])
        end