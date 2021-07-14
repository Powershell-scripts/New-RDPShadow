    function New-RDPShadow {
        <#
        .SYNOPSIS
        Создает новое подключение по теневому РДП  
        
        .DESCRIPTION
        Мы можем как ввести данные в ручную с помощью IDUser и PCName 
        Либо ввести данные имени ПК (PCName) а потом вызовется функция Get-UserLogged с параметром PCName для последующего подключения
        
        .PARAMETER -IDUser
        Необязательный параметр равный ID пользователя. Если не указан, то функция вызывает Get-UserLogged для получения ID
        
        
        .PARAMETER -PCName
        Обязательный параметр равный Имени ПК. Обязательно должен быть указан. 
        Принимает только Имя ПК. Например ilc-pvl-cash1 или *pvl-cash* - если не в курсе что за комп, но есть понимание как он должен называться
        * - это флаг любого символа
        
        .EXAMPLE
         New-RDPShadow -PCName *pvl-cash* 
         Осуществит подключение к кассе на павелецкой с первой активной сессией 
        
        .EXAMPLE
         New-RDPShadow -PCName *pvl-cash* -IDUser 1
         Осуществит подключение к кассе на павелецкой к сессии с номером 1 
        
        
        .NOTES
         Author: Chentsov_VS
        
        #>
            param (
                $IDUser,
                [Parameter(Mandatory = $true)]
                [string]$PCName
                )
            
            if ($null -eq $IDUser) {
                $Data = get-UserLogged -PCName $PCName
                $ID = $Data.UserID
                $ComputerName = $Data.ComputerName
                $Message = "Подключаюсь к машине " + $ComputerName + " c именем пользователя " + $ID
                mstsc /shadow:$id /v:$ComputerName /control 
                }
        
            elseif ($null -ne $IDUser) {
                $ErrorMessage = "Не должно быть больше двух ПК в списке. Посмотри и вбей нужный." + "`n`r" + "Список ниже: "
                $PCNames = Get-ADComputer -Filter "name -like '$PCName'"
                
                if ($PCNames.name.count -gt 1) {
                    $ComputerNames = $PCNames.Name
                    $ErrorMessage + "`n`r" + "$ComputerNames"
                    break
                    }
        
                else {
                    $ComputerName = $PCNames.Name
                    }
        
                $Message = "Подключаюсь к машине " + $ComputerNames + " c ID пользователя " + $IDUser
                mstsc /shadow:$IDUser /v:$ComputerName /control 
                }
        
            else {
                $Message = "Нет данных для подключения или я не могу подключится к " + "$PCName "
                }
        
            Return $Message 
        }