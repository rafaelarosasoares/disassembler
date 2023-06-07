
/* função para o cálculo do fatorial de um número n. Usamos uma função recursiva */
/******************/
int fatorial(int n)
/******************/
{     
        if(n==0) return 1;        
        else return n * fatorial(n-1); 
}


/* calculamos o fatorial de k=5, igual a 120 */
/**************/
void main(void)
/**************/
{     
        int k;    
        k = 5;
        k = fatorial(k);  
        printf("%d", k); /* na tradução para assembly, simplificar este procedimento */
        return;
} 
