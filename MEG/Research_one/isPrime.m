% 定义质数检查函数
function result = isPrime(n,N)
    if n <= 1
        result = false;
        return;
    end

    n2=unique(N(:,1));


    for i = 1:length(n2)
        n3=n2(i);

         n3(n3==n)=[];

        if mod(n, n3) == 0
            result = false;
            return;
        end
    end
    result = true;
end


