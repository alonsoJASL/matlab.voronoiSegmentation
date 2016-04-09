function [n] = getPrimes(N,nextPrime)
%   GET THE FIRST N PRIMES
% Returns an array of the first N prime numbers to be used as labels. If
% paired with the nextPrime (boolean) option, it returns the next prime
% that comes after N (e.g. N=5 would return n=7).
%

if nargin < 2
    nextPrime = false;
end

N=fix(N);


if nextPrime == 0
    idx = 10;
    x=primes(idx*N);
    
    while length(x)<N
        idx = idx*2;
        x=primes(idx*N);
    end
    
    if length(x)==N
        n=x;
    else
        indx = 1:N;
        n=x(indx);
    end
    
elseif N==1
    n = 2;
else
    x = primes(10000); % unlikely to need more..
    indx = find(x<=N);
    n = x(indx(end)+1);
    
end
